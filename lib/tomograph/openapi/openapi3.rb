require 'tomograph/tomogram/action'

module Tomograph
  module OpenApi
    class OpenApi3
      def initialize(prefix, openapi3_yaml_path)
        @prefix = prefix
        @documentation = YAML.safe_load(File.read(openapi3_yaml_path))
      end

      def to_tomogram
        @tomogram ||= @documentation['paths'].each_with_object([]) do |(path, action_definition), result|
          action_definition.keys.each do |method|
            ajj = valuekey(action_definition[method]['requestBody'], 'content')
            aj = valuekey(ajj, 'application/json')

            result.push(Tomograph::Tomogram::Action.new(
                          path: "#{@prefix}#{path}",
                          method: method.upcase,
                          content_type: action_definition[method]['requestBody'] && action_definition[method]['requestBody']['content'].keys[0] == 'application/json' ? action_definition[method]['requestBody']['content'].keys[0] : nil,
                          requests: [schema_new(valuekey(aj, 'schema'), @documentation['definitions'])].compact,
                          responses: responses(action_definition[method]['responses']),
                          resource: ''
                        ))
          end
        end
      end

      def valuekey(value, key)
        value.nil? ? nil : value[key]
      end

      def schema_new(sche, defi)
        return sche unless sche
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

      def responses(responses_definitions)
        result = []
        responses_definitions.each do |(response_code, response)|
          # response can be either Response Object or Reference Object
          if response.key?('$ref')
            response_description_path = response['$ref'].split('/')[1..] # first one is a '#'
            response['content'] = @documentation.dig(*response_description_path)['content']
          end

          # Content can be nil if response body is not provided
          if response['content'].nil?
            result.push(
              'status' => response_code,
              'body'=> {},
              'content-type' => nil
            )
          else
            result += responses_by_content_types(response['content'], response_code)
          end
        end
        result
      end

      def responses_by_content_types(content_types, response_code)
        content_types.map do |content_type, media_type_obj|
          {
            'status' => response_code,
            'body' => schema(media_type_obj['schema']),
            'content-type' => content_type
          }
        end
      end

      def schema(sche)
        if @documentation['components']
          defi = @documentation['components']['schemas']
        elsif @documentation['definitions']
          defi = @documentation['definitions']
        end
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
            res['definitions'].merge!({ key.split('/')[-1] => defi[key.split('/')[-1]] })
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
