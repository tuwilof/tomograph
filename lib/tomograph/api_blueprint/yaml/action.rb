require 'tomograph/tomogram/action'

module Tomograph
  module ApiBlueprint
    class Yaml
      class Action
        def initialize(content, path, resource)
          @content = content
          @path = path
          @resource = resource
        end

        attr_reader :path, :resource

        def method
          @method ||= @content.first['attributes']['method']
        end

        def request
          return @request if @request

          request_action = @content.find { |el| el['element'] == 'httpRequest' }
          @request = json_schema(request_action['content'])
        end

        def json_schema(actions)
          schema_node = actions.find do |action|
            action && action['element'] == 'asset' && action['attributes']['contentType'] == 'application/schema+json'
          end
          return {} unless schema_node

          MultiJson.load(schema_node['content'])
        rescue MultiJson::ParseError => e
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
              'status' => response['attributes']['statusCode'],
              'body' => json_schema(response['content'])
            }
          end
        end
      end
    end
  end
end
