require 'tomograph/path'
require 'tomograph/request/json_schema'
require 'tomograph/response/json_schema'

module Tomograph
  class Action
    def initialize(content, path, prefix)
      @content = content['content']
      @source_path = path
      @prefix = prefix
    end

    def path
      @path ||= "#{@prefix}#{Tomograph::Path.new(@source_path)}"
    end

    def method
      @content.first['attributes']['method']
    end

    def request
      Tomograph::Request::JsonSchema.new(@content).to_hash
    end

    def responses
      @responses ||= @content.select {|response| Tomograph::Response::JsonSchema.valid?(response)}.map do |response|
        Tomograph::Response::JsonSchema.new(response).to_hash
      end
    end

    def add_responses(re_responses)
      @responses = re_responses
    end

    def to_hash
      @action ||= {
        'path' => path,
        'method' => method,
        'request' => request,
        'responses' => responses
      }
    end

    def find_responses(status:)
      to_hash['responses'].find_all do |response|
        response['status'] == status.to_s
      end
    end

    def set_path_regexp(regexp)
      @regexp = regexp
    end

    def path_regexp
      @regexp
    end
  end
end
