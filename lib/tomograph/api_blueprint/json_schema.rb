require 'tomograph/tomogram/action'

module Tomograph
  module ApiBlueprint
    class JsonSchema
      def initialize(prefix, json_schema_path)
        @prefix = prefix
        @documentation = MultiJson.load(File.read(json_schema_path))
      end

      def to_tomogram
        @tomogram ||= @documentation.inject([]) do |result, action|
          result.push(Tomograph::Tomogram::Action.new(
                        path: "#{@prefix}#{action['path']}",
                        method:  action['method'],
                        content_type: action['content-type'],
                        request: action['request'],
                        responses: action['responses'],
                        resource: action['resource']))
        end
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
