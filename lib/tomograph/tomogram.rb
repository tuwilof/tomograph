require 'multi_json'

module Tomograph
  class Tomogram < String
    def json
      @result ||= find_resource.inject([]) do |result, single_sharp|
        result += single_sharp['content'].inject([]) do |result, resource|
          next result if text_node?(resource)

          result.concat(extract_actions(resource))
        end
      end
      MultiJson.dump(@result)
    end

    def delete_query_and_last_slash(path)
      path = delete_till_the_end(path, '{&')
      path = delete_till_the_end(path, '{?')

      remove_the_slash_at_the_end(path)
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
  end
end
