require 'multi_json'

module Tomograph
  class Tomogram < String
    class << self
      def json
        single_sharp = find_resource

        res = Array.new(single_sharp['content'].inject([]) do |result, controller|
          next result if controller['content'].is_a? String # skip header
          result.push(controller['content'].inject([]) do |actions, action|
            actions.push(action(controller, action))
          end).flatten
        end)
        MultiJson.dump(res)
      end

      def delete_query_and_last_slash(path)
        path = delete_till_the_end(path, '{&')
        path = delete_till_the_end(path, '{?')
        path = remove_the_slash_at_the_end(path)
        path
      end

      private

      def find_resource
        documentation['content'][0]['content'].find do |resource|
          !resource['content'].is_a?(String) && # skip description
            resource['meta']['classes'][0] == 'resourceGroup' # skip Data Structures
        end
      end

      def documentation
        YAML.load(File.read("#{Rails.root}/#{Tomograph.configuration.documentation}"))
      end

      def delete_till_the_end(path, beginning_with)
        path_index = path.index(beginning_with)
        path_index ||= 0
        path_index -= 1
        path.slice(0..path_index)
      end

      def remove_the_slash_at_the_end(path)
        if path[-1] == '/'
          path[0..-2]
        else
          path
        end
      end

      def action(controller, action)
        path = action['attributes']['href'] unless action['attributes'].nil?
        path ||= controller['attributes']['href']
        action_to_hash(action, path)
      end

      def action_to_hash(action, path)
        {
          'path' => "#{Tomograph.configuration.prefix}#{delete_query_and_last_slash(path)}",
          'method' => action['content'].last['content'][0]['attributes']['method'],
          'request' => request(action),
          'responses' => responses(action)
        }
      end

      def request(action)
        return {} if find_action?(action).nil?
        begin
          MultiJson.load(find_action?(action)['content'])
        rescue MultiJson::ParseError
          {}
        end
      end

      def find_action?(action)
        action['content'].last['content'].first['content'].last
      end

      def responses(action)
        action['content'].inject([]) do |responses, response|
          next responses if response['content'].is_a? String # skip comment

          next responses if response['content'][1]['attributes'].nil? # skip if responses nil
          responses.push(response(response))
        end
      end

      def response(response)
        {
          'status' => response['content'][1]['attributes']['statusCode'],
          'body' => json_schema(response)
        }
      end

      def json_schema(response)
        json_schema = response['content'][1]['content']
        return {} if json_schema.size == 1
        return {} if json_schema.empty?
        return MultiJson.load(json_schema[2]['content']) if json_schema[2]
        {}
      end
    end
  end
end
