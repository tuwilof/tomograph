require 'json'
require 'tomograph/path'
require 'tomograph/api_blueprint/json_schema'
require 'tomograph/api_blueprint/drafter_4/yaml'
require 'tomograph/api_blueprint/crafter/yaml'

module Tomograph
  class Tomogram
    extend Gem::Deprecate

    def initialize(prefix: '', drafter_yaml_path: nil, tomogram_json_path: nil, crafter_yaml_path: nil)
      @documentation = if tomogram_json_path
                         Tomograph::ApiBlueprint::JsonSchema.new(prefix, tomogram_json_path)
                       elsif crafter_yaml_path
                         Tomograph::ApiBlueprint::Crafter::Yaml.new(prefix, crafter_yaml_path)
                       else
                         Tomograph::ApiBlueprint::Drafter4::Yaml.new(prefix, drafter_yaml_path)
                       end
      @prefix = prefix
    end

    def to_a
      @actions ||= @documentation.to_tomogram
    end

    def to_hash
      to_a.map(&:to_hash)
    end
    deprecate :to_hash, 'to_a with method access', 2018, 8

    def to_json
      JSON.pretty_generate(to_a.map(&:to_hash))
    end

    def find_request(method:, path:)
      path = Tomograph::Path.new(path).to_s

      to_a.find do |action|
        action.method == method && action.path.match(path)
      end
    end

    def find_request_with_content_type(method:, path:, content_type:)
      path = Tomograph::Path.new(path).to_s

      to_a.find do |action|
        action.method == method && action.path.match(path) && action.content_type == content_type
      end
    end

    def to_resources
      @resources ||= @documentation.to_resources
    end

    def prefix_match?(raw_path)
      raw_path.include?(@prefix)
    end
  end
end
