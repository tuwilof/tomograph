require 'tomograph/tomogram/action'
require 'tomograph/openapi/external_ref_resolver'

module Tomograph
  module OpenApi
    class OpenApi3
      HTTP_METHODS = %w[get put post delete options head patch trace].freeze
      REQUEST_SCHEMA_TYPES = ['application/json', 'multipart/form-data', 'application/x-www-form-urlencoded'].freeze

      def initialize(prefix, openapi3_yaml_path)
        @prefix = prefix
        @documentation = ExternalRefResolver.load(openapi3_yaml_path)
      end

      def to_tomogram
        @tomogram ||= @documentation['paths'].each_with_object([]) do |(path, action_definition), result|
          next unless action_definition.is_a?(Hash)

          action_definition.each do |method, operation|
            next unless HTTP_METHODS.include?(method)
            next unless operation.is_a?(Hash)

            request_body = operation['requestBody']
            content = valuekey(request_body, 'content')
            result.push(Tomograph::Tomogram::Action.new(
                          path: "#{@prefix}#{path}",
                          method: method.upcase,
                          content_type: request_body.nil? ? nil : content&.keys&.first,
                          requests: [request_schema(content)].compact,
                          responses: responses(operation['responses']),
                          resource: ''
                        ))
          end
        end
      end

      def valuekey(value, key)
        value.nil? ? nil : value[key]
      end

      def request_schema(content)
        return if content.nil?

        type = REQUEST_SCHEMA_TYPES.find { |item| content.key?(item) }
        return if type.nil?

        node = valuekey(content[type], 'schema')
        return if node.nil?

        if node.to_s.include?('#/components/schemas/')
          schema(node)
        else
          schema_new(node, @documentation['definitions'])
        end
      end

      def schema_new(sche, defi)
        json_schema(schema_new_raw(sche, defi))
      end

      def schema_new_raw(sche, defi)
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
              'body' => {},
              'content-type' => nil
            )
          else
            result += responses_by_content_types(response['content'], response_code)
          end

          # API Blueprint allowed a second response with the same status and an
          # empty body. Fitting treats that pair as an optional schema.
          if response['x-empty-body']
            result.push(
              'status' => response_code,
              'body' => {},
              'content-type' => 'application/json'
            )
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
        json_schema(schema_raw(sche))
      end

      def schema_raw(sche)
        return sche unless sche.is_a?(Hash)

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
          res = attach_definitions(sche, defi)
          attach_component_schemas(res)
        else
          sche
        end
      end

      def attach_definitions(sche, defi)
        keys = sche.to_s.split('"').find_all { |word| word.include?('definitions') }
        return sche if keys.empty?

        res = sche.merge('definitions' => {})
        keys.each do |key|
          name = key.split('/')[-1]
          res['definitions'].merge!(name => defi[name])
        end
        res
      end

      def attach_component_schemas(sche)
        schemas = @documentation.dig('components', 'schemas')
        return sche unless schemas

        copied = {}
        seen = {}
        copy_component_schemas(copied, seen, component_ref_names(sche), schemas)
        return sche if copied.empty?

        previous = (sche['components'] || {})
        schemas = (previous['schemas'] || {}).merge(copied)
        sche.merge('components' => previous.merge('schemas' => schemas))
      end

      def copy_component_schemas(copied, seen, names, schemas)
        names.each do |name|
          next if seen[name]
          next unless schemas[name]

          seen[name] = true
          copied[name] = schemas[name]
          copy_component_schemas(copied, seen, component_ref_names(schemas[name]), schemas)
        end
      end

      def component_ref_names(schema)
        schema.to_s.split('"').find_all { |word| word.include?('#/components/schemas/') }
              .map { |word| word[21..-1] }
              .uniq
      end

      # OpenAPI 3 `nullable: true` is not a JSON Schema keyword. Draft-04, which
      # the tomogram is validated against, allows null only via the type list.
      def json_schema(node)
        case node
        when Hash
          converted = {}
          node.each { |key, value| converted[key] = json_schema(value) }
          nullable_to_type(converted)
        when Array
          node.map { |value| json_schema(value) }
        else
          node
        end
      end

      def nullable_to_type(schema)
        return schema unless schema.key?('nullable')

        nullable = schema.delete('nullable')
        return schema unless nullable

        case schema['type']
        when String
          schema['type'] = [schema['type'], 'null']
        when Array
          schema['type'] = schema['type'].dup
          schema['type'] << 'null' unless schema['type'].include?('null')
        end
        schema
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
