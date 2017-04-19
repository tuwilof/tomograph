require 'tomograph/path'

module Tomograph
  class Tomogram
    class Action
      def initialize(action, prefix)
        @content = action['content']
        @source_path = action['transition_path']
        @prefix = prefix
      end

      def path
        @path ||= "#{@prefix}#{Tomograph::Path.new(@source_path)}"
      end

      def method
        @method ||= @content.first['attributes']['method']
      end

      def request
        return @request if @request

        request_action = @content.find {|el| el['element'] == 'httpRequest'}
        @request = json_schema(request_action['content'])
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

      def add_responses(re_responses)
        @responses = re_responses
      end

      def to_hash
        @action ||= {
          'path' => path,
          'method' => method,
          'request' => request,
          'responses' => responses
        }
      end

      def find_responses(status:)
        to_hash['responses'].find_all do |response|
          response['status'] == status.to_s
        end
      end

      def match_path(find_path)
        return @regexp =~ find_path if @regexp

        str = Regexp.escape(path)
        str = str.gsub(/\\{\w+\\}/, '[^&=\/]+')
        str = "\\A#{str}\\z"
        @regexp = Regexp.new(str)
        @regexp =~ find_path
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
    end
  end
end
