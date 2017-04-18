module Tomograph
  class JsonSchema
    def initialize(actions)
      schema_node = actions.find { |action| valid?(action) }
      unless schema_node
        @json_schema = {}
        return
      end

      @json_schema = MultiJson.load(schema_node['content'])
    rescue MultiJson::ParseError => e
      puts "[Tomograph] Error while parsing #{e}. skipping..."
      @json_schema = {}
    end

    def valid?(action)
      action && action['element'] == 'asset' && action['attributes']['contentType'] == 'application/schema+json'
    end

    def to_hash
      @json_schema
    end
  end
end
