require 'multi_json'
require 'tomograph/tomogram/action'
require 'tomograph/path'
require 'tomograph/api_blueprint/yaml'

module Tomograph
  class Tomogram
    def initialize(apib_path: nil, drafter_yaml_path: nil, drafter_yaml: nil, prefix: '')
      @documentation = Tomograph::ApiBlueprint::Yaml.new(apib_path, drafter_yaml, drafter_yaml_path)
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
      return @tomogram if @tomogram

      actions = @documentation.resources.inject([]) do |result_resources, resource|
        result_resources + actions_of_resource(resource, resource_path(resource))
      end
      @tomogram = combine_by_responses(actions)
    end

    def actions_of_resource(resource, resource_path)
      resource['content'].inject([]) do |result_transition, transition|
        next result_transition unless transition?(transition)
        result_transition + actions_of_transition(transition, transition_path(transition, resource_path))
      end
    end

    def actions_of_transition(transition, transition_path)
      transition['content'].inject([]) do |result_content, content|
        next result_content unless content?(content)
        result_content.push(Tomograph::Tomogram::Action.new(content, transition_path, @prefix))
      end
    end

    def combine_by_responses(actions)
      actions.group_by {|action| action.method + action.path}.map do |_key, related_actions|
        related_actions.first.add_responses(related_actions.map(&:responses).flatten)
        related_actions.first
      end.flatten
    end

    def resource_path(resource)
      resource['attributes'] && resource['attributes']['href']
    end

    def transition?(transition)
      transition['element'] == 'transition'
    end

    def transition_path(transition, resource_path)
      transition['attributes'] && transition['attributes']['href'] || resource_path
    end

    def content?(content)
      content['element'] == 'httpTransaction'
    end
  end
end
