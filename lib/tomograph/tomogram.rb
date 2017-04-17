require 'multi_json'
require 'tomograph/request'
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
      compile_path_patterns
    end

    def to_hash
      @result
    end

    def json
      MultiJson.dump(@result.map do |res|
        {
          'path' => res['path'],
          'method' => res['method'],
          'request' => res['request'],
          'responses' => res['responses']
        }
      end)
    end

    def find_request(method:, path:)
      path = find_request_path(method: method, path: path)
      @result.find do |doc|
        doc['path'] == path && doc['method'] == method
      end
    end

    def compile_path_patterns
      @result.each do |action|
        next unless (path = action['path'])

        regexp = compile_path_pattern(path)
        action['path_regexp'] = regexp
      end
    end

    private

    def actions(resource)
      result_actions = []
      resource_path = resource['attributes'] && resource['attributes']['href']

      resource['content'].each do |transition|
        next unless transition['element'] == 'transition'

        path = transition['attributes'] && transition['attributes']['href'] || resource_path

        transition['content'].each do |content|
          next unless content['element'] == 'httpTransaction'

          result_actions.push(Tomograph::Action.new(content, path).to_hash)
        end
      end

      result_actions.group_by {|action| action['method'] + action['path']}.map do |_key, resource_actions|
        # because in yaml a response has a copy of the same request we can only use the first
        Request.new.merge(
          {
            'path' => resource_actions.first['path'],
            'method' => resource_actions.first['method'],
            'request' => resource_actions.first['request'],
            'responses' => resource_actions.flat_map {|action| action['responses']}.compact
          }
        )
      end
    end

    def compile_path_pattern(path)
      str = Regexp.escape(path)
      str = str.gsub(/\\{\w+\\}/, '[^&=\/]+')
      str = "\\A#{ str }\\z"
      Regexp.new(str)
    end

    def find_request_path(method:, path:)
      return '' unless path && path.size > 0

      path = normalize_path(path)

      action = search_for_an_exact_match(method, path, @result)
      return action['path'] if action

      action = search_with_parameter(method, path, @result)
      return action['path'] if action

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
        action['path'] == path && action['method'] == method
      end
    end

    def search_with_parameter(method, path, documentation)
      documentation = actions_with_same_method(documentation, method)

      documentation.find do |action|
        next unless regexp = action['path_regexp']
        regexp =~ path
      end
    end

    def actions_with_same_method(documentation, method)
      documentation.find_all do |doc|
        doc['method'] == method
      end
    end
  end
end
