require 'tomograph/json_schema'

module Tomograph
  class Request
    class JsonSchema
      def initialize(actions)
        request_action = actions.find { |el| el['element'] == 'httpRequest' }
        @json_schema = Tomograph::JsonSchema.new(request_action['content']).to_hash
      end

      def to_hash
        @json_schema
      end
    end
  end
end
