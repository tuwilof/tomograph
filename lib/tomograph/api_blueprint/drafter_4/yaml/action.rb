require 'tomograph/tomogram/action'

module Tomograph
  module ApiBlueprint
    class Drafter4
      class Yaml
        class Action
          def initialize(content, path, resource)
            @content = content
            @path = path
            @resource = resource
          end

          attr_reader :path, :resource

          def method
            @method ||= @content.first['attributes']['method']['content']
          end

          def content_type
            if @content.first['attributes'].key?('headers') &&
               @content.first['attributes']['headers']['content'][0]['content']['key']['content'] == 'Content-Type'
              @content.first['attributes']['headers']['content'][0]['content']['value']['content']
            end
          end

          def request
            return @request if @request

            request_action = @content.find { |el| el['element'] == 'httpRequest' }
            @request = json_schema(request_action['content'])
          end

          def json_schema(actions)
            schema_node = actions.find do |action|
              action && action['element'] == 'asset' &&
                action['attributes']['contentType']['content'] == 'application/schema+json'
            end
            return {} unless schema_node

            JSON.parse(schema_node['content'])
          rescue JSON::ParserError => e
            puts "[Tomograph] Error while parsing #{e}. skipping..."
            {}
          end

          def responses
            return @responses if @responses

            @responses = @content.select do |response|
              response['element'] == 'httpResponse' && response['attributes']
            end
            @responses = @responses.map do |response|
              content_type = if response['attributes'].key?('headers')
                               response['attributes']['headers']['content'][0]['content']['value']['content']
                             end

              {
                'status' => response['attributes']['statusCode']['content'].to_s,
                'body' => json_schema(response['content']),
                'content-type' => content_type
              }
            end
          end
        end
      end
    end
  end
end
