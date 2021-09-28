require 'tomograph/tomogram/action'

module Tomograph
  module ApiBlueprint
    class Crafter
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
            if @content.first['attributes'].has_key?('headers')
              @content.first['attributes']['headers']['content'][0]['content']['key']['content'] == 'Content-Type' ?
                @content.first['attributes']['headers']['content'][0]['content']['value']['content'] : nil
            end
          end

          def request
            return @request if @request

            request_action = @content.find { |el| el['element'] == 'httpRequest' }
            @request = json_schema(request_action['content'])
          end

          def json_schema(actions)
            schema_node = actions.find do |action|
              action && action.fetch('element', nil) == 'asset' && action.fetch('attributes', {}).fetch('contentType', {}).fetch('content', nil) == 'application/schema+json'
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
              {
                'status' => response['attributes']['statusCode']['content'].to_s,
                'body' => json_schema(response['content']),
                'content-type' => response['attributes'].has_key?('headers') ?
                  response['attributes']['headers']['content'][0]['content']['value']['content'] : nil
              }
            end
          end
        end
      end
    end
  end
end
