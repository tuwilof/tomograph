require 'multi_json'
require 'tomograph/documentation'
require 'tomograph/resources'
require 'tomograph/action'

module Tomograph
  class Tomogram
    def initialize(apib_path: nil, drafter_yaml_path: nil, drafter_yaml: nil, prefix: '')
      @documentation = Documentation.new(
        apib_path: apib_path,
        drafter_yaml: drafter_yaml,
        drafter_yaml_path: drafter_yaml_path
      )
      @prefix = prefix
      @result = @documentation.to_hash['content'][0]['content'].inject([]) do |result_resources, group|
        if group['element'] == 'copy' || # Element is a human readable text
          group['meta']['classes'][0] != 'resourceGroup' # skip Data Structures
          next result_resources
        end

        result_resources + group['content'].inject([]) do |result_actions, resource|
          if resource['element'] == 'copy' # Element is a human readable text
            next result_actions
          end

          result_actions + actions(resource)
        end
      end
    end

    def to_hash
      @result
    end

    def json
      MultiJson.dump(@result.map do |action|
        action.to_hash
      end)
    end

    def find_request(method:, path:)
      path = find_request_path(method: method, path: path)
      @result.find do |doc|
        doc.path == path && doc.method == method
      end
    end

    private

    def actions(resource)
      resource_path = resource['attributes'] && resource['attributes']['href']

      resource['content'].inject([]) do |result_actions, transition|
        next result_actions unless transition['element'] == 'transition'

        path = transition['attributes'] && transition['attributes']['href'] || resource_path

        transition['content'].each do |content|
          next unless content['element'] == 'httpTransaction'

          result_actions.push(Tomograph::Action.new(content, path, @prefix))
        end
        result_actions
      end.group_by {|action| action.method + action.path}.map do |_key, related_actions|
        related_actions.first.add_responses(related_actions.map {|acts| acts.responses}.flatten)
        related_actions.first
      end.flatten
    end

    def find_request_path(method:, path:)
      return '' unless path && path.size > 0

      path = normalize_path(path)

      action = search_for_an_exact_match(method, path, @result)
      return action.path if action

      action = search_with_parameter(method, path, @result)
      return action.path if action

      ''
    end

    def normalize_path(path)
      path = cut_off_query_params(path)
      remove_the_slash_at_the_end2(path)
    end

    def remove_the_slash_at_the_end2(path)
      return path[0..-2] if path[-1] == '/'
      path
    end

    def cut_off_query_params(path)
      path.gsub(/\?.*\z/, '')
    end

    def search_for_an_exact_match(method, path, documentation)
      documentation.find do |action|
        action.path == path && action.method == method
      end
    end

    def search_with_parameter(method, path, documentation)
      documentation = actions_with_same_method(documentation, method)

      documentation.find do |action|
        next unless regexp = action.path_regexp
        regexp =~ path
      end
    end

    def actions_with_same_method(documentation, method)
      documentation.find_all do |doc|
        doc.method == method
      end
    end
  end
end
