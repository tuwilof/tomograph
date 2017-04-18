require 'multi_json'
require 'tomograph/documentation'
require 'tomograph/action'
require 'tomograph/path'

module Tomograph
  class Tomogram
    def initialize(apib_path: nil, drafter_yaml_path: nil, drafter_yaml: nil, prefix: '')
      @documentation = Documentation.new(
        apib_path: apib_path,
        drafter_yaml: drafter_yaml,
        drafter_yaml_path: drafter_yaml_path
      )
      @prefix = prefix
    end

    def to_hash
      tomogram.map(&:to_hash)
    end

    def to_json
      MultiJson.dump(to_hash)
    end

    def find_request(method:, path:)
      path = Tomograph::Path.new(path).to_s

      tomogram.find do |action|
        action.method == method && action.match_path(path)
      end
    end

    private

    def tomogram
      @tomogram ||= @documentation.to_hash['content'][0]['content'].inject([]) do |result_resources, group|
        if group['element'] == 'copy' || # Element is a human readable text
           group['meta']['classes'][0] != 'resourceGroup' # skip Data Structures
          next result_resources
        end

        result_resources + group['content'].inject([]) do |result_actions, resource|
          next result_actions if resource['element'] == 'copy' # Element is a human readable text

          result_actions + actions(resource)
        end
      end
    end

    def actions(resource)
      resource_path = resource['attributes'] && resource['attributes']['href']

      resource['content'].each_with_object([]) do |transition, result_actions|
        next result_actions unless transition['element'] == 'transition'

        path = transition['attributes'] && transition['attributes']['href'] || resource_path

        transition['content'].each do |content|
          next unless content['element'] == 'httpTransaction'

          result_actions.push(Tomograph::Action.new(content, path, @prefix))
        end
      end.group_by { |action| action.method + action.path }.map do |_key, related_actions|
        related_actions.first.add_responses(related_actions.map(&:responses).flatten)
        related_actions.first
      end.flatten
    end
  end
end
