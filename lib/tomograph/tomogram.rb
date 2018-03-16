require 'multi_json'
require 'tomograph/path'
require 'tomograph/api_blueprint/yaml'

module Tomograph
  class Tomogram
    def initialize(prefix: '', apib_path: nil, drafter_yaml_path: nil)
      @documentation = Tomograph::ApiBlueprint::Yaml.new(prefix, apib_path, drafter_yaml_path)
      @prefix = prefix
    end

    def to_hash
      @documentation.to_tomogram.map(&:to_hash)
    end

    def to_json
      MultiJson.dump(to_hash)
    end

    def find_request(method:, path:)
      path = Tomograph::Path.new(path).to_s

      @documentation.to_tomogram.find do |action|
        action.method == method && action.path.match(path)
      end
    end

    def find_request_with_content_type(method:, path:, content_type:)
      path = Tomograph::Path.new(path).to_s

      @documentation.to_tomogram.find do |action|
        action.method == method && action.path.match(path) && action.content_type == content_type
      end
    end

    def to_resources
      @documentation.to_resources
    end

    def prefix_match?(raw_path)
      raw_path.include?(@prefix)
    end
  end
end
