require 'tomograph/json_schema'

module Tomograph
  class Response
    class JsonSchema
      def initialize(response)
        @json_schema = {
          'status' => response['attributes']['statusCode'],
          'body' => Tomograph::JsonSchema.new(response['content']).to_hash
        }
      end

      def to_hash
        @json_schema
      end

      def self.valid?(response)
        response['element'] == 'httpResponse' && response['attributes']
      end
    end
  end
end
