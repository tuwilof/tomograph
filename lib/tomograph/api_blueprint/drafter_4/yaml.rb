require 'yaml'
require 'tomograph/api_blueprint/drafter_4/yaml/action'
require 'tomograph/tomogram/action'

module Tomograph
  module ApiBlueprint
    class Drafter4
      class Yaml
        def initialize(prefix, apib_path, drafter_yaml_path)
          @prefix = prefix
          @documentation = if apib_path
                             YAML.safe_load(`drafter #{apib_path}`)
                           elsif drafter_yaml_path
                             YAML.safe_load(File.read(drafter_yaml_path))
                           end
        end

        def groups
          @groups ||= @documentation['content'][0]['content'].each_with_object([]) do |group, result_groups|
            result_groups.push(group) if group?(group)
            result_groups.push('content' => [group]) if single_resource?(group)
          end
        end

        def single_resource?(group)
          group['element'] == 'resource'
        end

        def group?(group)
          return false if group['element'] == 'resource'
          group['element'] != 'copy' && # Element is a human readable text
            group['meta']['classes']['content'][0]['content'] == 'resourceGroup' # skip Data Structures
        end

        def resources
          @resources ||= groups.inject([]) do |result_groups, group|
            result_groups.push(group['content'].each_with_object([]) do |resource, result_resources|
              result_resources.push('resource' => resource, 'resource_path' => resource_path(resource)) if resource?(resource)
            end)
          end.flatten
        end

        def resource?(resource)
          resource['element'] != 'copy' # Element is a human readable text
        end

        def resource_path(resource)
          resource['attributes'] && resource['attributes']['href']['content']
        end

        def transitions
          @transitions ||= resources.inject([]) do |result_resources, resource|
            result_resources.push(resource['resource']['content'].each_with_object([]) do |transition, result_transitions|
              result_transitions.push(transition_hash(transition, resource)) if transition?(transition)
            end)
          end.flatten
        end

        def transition?(transition)
          transition['element'] == 'transition'
        end

        def transition_hash(transition, resource)
          {
            'transition' => transition,
            'transition_path' => transition_path(transition, resource['resource_path']),
            'resource' => resource['resource_path']
          }
        end

        def transition_path(transition, resource_path)
          transition['attributes'] && transition['attributes']['href']['content'] || resource_path
        end

        def without_group_actions
          transitions.inject([]) do |result_transition, transition|
            result_transition.push(transition['transition']['content'].each_with_object([]) do |content, result_contents|
              result_contents.push(Tomograph::ApiBlueprint::Drafter4::Yaml::Action.new(
                                     content['content'],
                                     transition['transition_path'],
                                     transition['resource']
              )) if action?(content)
            end)
          end
        end

        def action?(content)
          content['element'] == 'httpTransaction'
        end

        def actions
          @actions ||= without_group_actions
                       .flatten
                       .group_by { |action| "#{action.method} #{action.path}" }.map do |_key, related_actions|
            action_hash(related_actions)
          end.flatten
        end

        def action_hash(related_actions)
          {
            path: "#{@prefix}#{related_actions.first.path}",
            method: related_actions.first.method,
            content_type: related_actions.first.content_type,
            request: related_actions.first.request,
            responses: related_actions.map(&:responses).flatten,
            resource: related_actions.first.resource
          }
        end

        def to_tomogram
          @tomogram ||= actions.inject([]) do |result, action|
            result.push(Tomograph::Tomogram::Action.new(**action))
          end
        end

        def to_resources
          return @to_resources if @to_resources

          @to_resources = actions.group_by { |action| action[:resource] }
          @to_resources = @to_resources.inject({}) do |res, related_actions|
            requests = related_actions[1].map do |action|
              "#{action[:method]} #{action[:path]}"
            end
            res.merge(related_actions[1].first[:resource] => requests)
          end
        end
      end
    end
  end
end
