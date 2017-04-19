require 'tomograph/api_blueprint/yaml/action'

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
        @groups ||= @documentation['content'][0]['content'].inject([]) do |result_groups, group|
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
            result_resources.push({'resource' => resource, 'resource_path' => resource_path(resource)})
          end)
        end.flatten
      end

      def resource?(resource)
        resource['element'] != 'copy' # Element is a human readable text
      end

      def resource_path(resource)
        resource['attributes'] && resource['attributes']['href']
      end

      def transitions
        @transitions ||= resources.inject([]) do |result_resources, resource|
          result_resources.push(resource['resource']['content'].inject([]) do |result_transitions, transition|
            next result_transitions unless transition?(transition)
            result_transitions.push({
              'transition' => transition,
              'transition_path' => transition_path(transition, resource['resource_path'])})
          end)
        end.flatten
      end

      def transition?(transition)
        transition['element'] == 'transition'
      end

      def transition_path(transition, resource_path)
        transition['attributes'] && transition['attributes']['href'] || resource_path
      end

      def actions
        @actions ||= transitions.inject([]) do |result_transition, transition|
          result_transition.push(transition['transition']['content'].inject([]) do |result_contents, content|
            next result_contents unless action?(content)
            result_contents.push(Tomograph::ApiBlueprint::Yaml::Action.new(
              content['content'], transition['transition_path']))
          end)
        end.flatten
      end

      def action?(content)
        content['element'] == 'httpTransaction'
      end
    end
  end
end
