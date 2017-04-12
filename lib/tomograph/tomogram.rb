require 'multi_json'
require 'tomograph/request'

module Tomograph
  class Tomogram
    def initialize
      docs = find_resource.inject([]) do |result, single_sharp|
        result += single_sharp['content'].inject([]) do |result, resource|
          next result if text_node?(resource)

          result.concat(extract_actions(resource))
        end
      end
      @result = Array.new(docs.inject([]) do |res, doc|
        res.push(Request.new.merge(doc))
      end)
      compile_path_patterns
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

    def delete_query_and_last_slash(path)
      path = delete_till_the_end(path, '{&')
      path = delete_till_the_end(path, '{?')

      remove_the_slash_at_the_end(path)
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

    def extract_actions(resource)
      actions = []
      resource_path = resource['attributes'] && resource['attributes']['href']

      transitions = resource['content']
      transitions.each do |transition|
        next unless transition['element'] == 'transition'

        path = transition['attributes'] && transition['attributes']['href'] || resource_path

        transition['content'].each do |content|
          next unless content['element'] == 'httpTransaction'

          action = build_action(content, path)
          actions << action if action
        end
      end

      actions.group_by { |action| action['method'] + action['path'] }.map do |_key, resource_actions|
        # because in yaml a response has a copy of the same request we can only use the first
        {
          'path' => resource_actions.first['path'],
          'method' => resource_actions.first['method'],
          'request' => resource_actions.first['request'],
          'responses' => resource_actions.flat_map { |action| action['responses'] }.compact
        }
      end
    end

    def find_resource
      documentation['content'][0]['content'].find_all do |resource|
        !text_node?(resource) &&
          resource['meta']['classes'][0] == 'resourceGroup' # skip Data Structures
      end
    end

    def documentation
      if Tomograph.configuration.drafter_yaml
        YAML.load(Tomograph.configuration.drafter_yaml)
      else
        YAML.load(File.read("#{Rails.root}/#{Tomograph.configuration.documentation}"))
      end
    end

    def delete_till_the_end(path, beginning_with)
      path_index = path.index(beginning_with)
      path_index ||= 0
      path_index -= 1
      path.slice(0..path_index)
    end

    def remove_the_slash_at_the_end(path)
      if path[-1] == '/'
        path[0..-2]
      else
        path
      end
    end

    def build_action(content, path)
      return if text_node?(content)

      action_to_hash(content['content'], path)
    end

    def action_to_hash(actions, path)
      {
        'path' => "#{Tomograph.configuration.prefix}#{delete_query_and_last_slash(path)}",
        'method' => actions.first['attributes']['method'],
        'request' => request(actions),
        'responses' => responses(actions)
      }
    end

    def request(actions)
      request_action = actions.find { |el| el['element'] === 'httpRequest' }
      json_schema(request_action['content'])
    end

    def json_schema?(action)
      action && action['element'] == 'asset' && action['attributes']['contentType'] == 'application/schema+json'
    end

    def responses(actions)
      response_actions = actions.select { |el| el['element'] === 'httpResponse' }

      response_actions.map do |response|
        return unless response['attributes'] # if no response

        {
          'status' => response['attributes']['statusCode'],
          'body' => json_schema(response['content'])
        }
      end.compact
    end

    def json_schema(actions)
      schema_node = actions.find { |action| json_schema?(action) }
      return {} unless schema_node

      MultiJson.load(schema_node['content'])
    rescue MultiJson::ParseError => e
      puts "[Tomograph] Error while parsing #{ e }. skipping..."
      {}
    end

    def text_node?(node)
      node['element'] == 'copy' # Element is a human readable text
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
