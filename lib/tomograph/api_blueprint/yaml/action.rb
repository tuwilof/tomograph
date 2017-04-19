require 'tomograph/tomogram/action'

module Tomograph
  module ApiBlueprint
    class Yaml
      class Action
        def initialize(content, path)
          @content = content
          @path = path
        end

        def path
          @path
        end

        def method
          @method ||= @content.first['attributes']['method']
        end

        def request
          return @request if @request

          request_action = @content.find {|el| el['element'] == 'httpRequest'}
          @request = json_schema(request_action['content'])
        end

        def json_schema(actions)
          schema_node = actions.find {|action| action && action['element'] == 'asset' && action['attributes']['contentType'] == 'application/schema+json'}
          unless schema_node
            return {}
          end

          MultiJson.load(schema_node['content'])
        rescue MultiJson::ParseError => e
          puts "[Tomograph] Error while parsing #{e}. skipping..."
          {}
        end

        def responses
          return @responses if @responses

          @responses = @content.select {|response| response['element'] == 'httpResponse' && response['attributes']}.map do |response|
            {
              'status' => response['attributes']['statusCode'],
              'body' => json_schema(response['content'])
            }
          end
        end

        def to_tomogram
          Tomograph::Tomogram::Action.new(
            path: path, method: method, request: request, responses: responses
          )
        end
      end
    end
  end
end
