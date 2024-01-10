require 'tomograph/tomogram/action'

module Tomograph
  module OpenApi
    class OpenApi3
      def initialize(prefix, openapi3_yaml_path)
        @prefix = prefix
        @documentation = YAML.safe_load(File.read(openapi3_yaml_path))
      end

      def to_tomogram
        @tomogram ||= @documentation['paths'].each_with_object([]) do |action, result|
          action[1].keys.each do |method|
            result.push(Tomograph::Tomogram::Action.new(
                          path: "#{@prefix}#{action[0]}",
                          method: method.upcase,
                          content_type: '',
                          requests: [],
                          responses: responses(action[1][method]['responses']),
                          resource: ''
                        ))
          end
        end
      end

      def responses(resp)
        resp.inject([]) do |result, response|
          if response[1]['content'].nil?
            # TODO: 403Forbidden
            result.push(
              'status' => response[0],
              'body' => {},
              'content-type' => 'application/json'
            )
          elsif response[1]['content'].values[0]['schema']
            result.push(
              'status' => response[0],
              'body' => schema(response[1]['content'].values[0]['schema']),
              'content-type' => 'application/json'
            )
          else
            result.push(
              status: response[0],
              body: {},
              'content-type': ''
            )
          end
        end
      end

      def schema(sche)
        defi = @documentation['components']['schemas']
        if sche.keys.include?('$ref')
          sche.merge!('components' => {})
          sche['components'].merge!('schemas' => {})
          sche['components']['schemas'].merge!({ sche['$ref'][21..-1] => defi[sche['$ref'][21..-1]] })

          if defi[sche['$ref'][21..-1]].to_s.include?('$ref')
            keys = defi[sche['$ref'][21..-1]].to_s.split('"').find_all { |word| word.include?('#/components/schemas/') }
            keys.each do |key|
              sche['components']['schemas'].merge!({ key[21..-1] => defi[key[21..-1]] })

              next unless defi[key[21..-1]].to_s.include?('$ref')

              keys2 = defi[key[21..-1]].to_s.split('"').find_all { |word| word.include?('#/components/schemas/') }
              keys2.each do |key2|
                sche['components']['schemas'].merge!({ key2[21..-1] => defi[key2[21..-1]] })

                next unless defi[key2[21..-1]].to_s.include?('$ref')

                keys3 = defi[key2[21..-1]].to_s.split('"')
                                          .find_all { |word| word.include?('#/components/schemas/') }
                                          .uniq
                keys3.each do |key3|
                  sche['components']['schemas'].merge!({ key3[21..-1] => defi[key3[21..-1]] })
                end
              end
            end
          end
          sche

        elsif sche.to_s.include?('$ref')
          res = sche.merge('definitions' => {})
          keys = sche.to_s.split('"').find_all { |word| word.include?('definitions') }
          keys.each do |key|
            res['definitions'].merge!({ key[21..-1] => defi[key[21..-1]] })
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
