module Tomograph
  module ApiBlueprint
    class Yaml
      def initialize(apib_path, drafter_yaml, drafter_yaml_path)
        @documentation = if apib_path
          `drafter #{apib_path}`
        elsif drafter_yaml
          YAML.safe_load(drafter_yaml)
        else
          YAML.safe_load(File.read("#{Rails.root}/#{drafter_yaml_path}"))
        end
      end

      def groups
        @groups ||= @documentation.to_hash['content'][0]['content'].inject([]) do |result_groups, group|
          next result_groups unless group?(group)
          result_groups.push(group)
        end
      end

      def group?(group)
        group['element'] != 'copy' && # Element is a human readable text
          group['meta']['classes'][0] == 'resourceGroup' # skip Data Structures
      end

      def resources
        @resources ||= groups.inject([]) do |result_groups, group|
          result_groups.push(group['content'].inject([]) do |result_resources, resource|
            next result_resources unless resource?(resource)
            result_resources.push(resource)
          end)
        end.flatten
      end

      def resource?(resource)
        resource['element'] != 'copy' # Element is a human readable text
      end
    end
  end
end
