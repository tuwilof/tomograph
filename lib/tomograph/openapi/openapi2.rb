require 'tomograph/tomogram/action'

module Tomograph
  module OpenApi
    class OpenApi2
      def initialize(prefix, json_schema_path)
        @prefix = prefix
        @documentation = JSON.parse(File.read(json_schema_path))
      end

      def to_tomogram
        @tomogram ||= @documentation['paths'].each_with_object([]) do |action, result|
          action[1].keys.each do |method|
            result.push(Tomograph::Tomogram::Action.new(
                          path: "#{@prefix}#{action[0]}",
                          method: method.upcase,
                          content_type: '',
                          requests: [],
                          responses: responses(action[1][method]['responses'], @documentation['definitions']),
                          resource: ''
                        ))
          end
        end
      end

      def responses(resp, defi)
        resp.inject([]) do |result, reponse|
          if reponse[1]['schema']
            result.push(
              status: reponse[0],
              body: schema(reponse[1]['schema'], defi),
              'content-type': ''
            )
          else
            result.push(
              status: reponse[0],
              body: {},
              'content-type': ''
            )
          end
        end
      end

      def schema(sche, defi)
        if sche.keys.include?('$ref')
          res = sche.merge('definitions' => { sche['$ref'][14..-1] => defi[sche['$ref'][14..-1]] })
          if defi[sche['$ref'][14..-1]].to_s.include?('$ref')
            keys = defi[sche['$ref'][14..-1]].to_s.split('"').find_all { |word| word.include?('definitions') }
            keys.each do |key|
              res['definitions'].merge!({ key[14..-1] => defi[key[14..-1]] })
            end
          end
          res
        elsif sche.to_s.include?('$ref')
          res = sche.merge('definitions' => {})
          keys = sche.to_s.split('"').find_all { |word| word.include?('definitions') }
          keys.each do |key|
            res['definitions'].merge!({ key[14..-1] => defi[key[14..-1]] })
          end
          res
        else
          sche
        end
      end

      def search_hash(hash, key)
        return hash[key] if hash.assoc(key)

        hash.delete_if { |_key, value| value.class != Hash }
        new_hash = {}
        hash.each_value { |values| new_hash.merge!(values) }
        search_hash(new_hash, key) unless new_hash.empty?
      end

      def to_resources
        return @to_resources if @to_resources

        @to_resources = @documentation.group_by { |action| action['resource'] }
        @to_resources = @to_resources.each_with_object({}) do |(resource, actions), resource_map|
          requests = actions.map do |action|
            "#{action['method']} #{@prefix}#{action['path']}"
          end
          resource_map[resource] = requests
        end
      end
    end
  end
end
