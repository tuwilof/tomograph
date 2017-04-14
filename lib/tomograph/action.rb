require 'tomograph/path'
require 'tomograph/request/json_schema'
require 'tomograph/response/json_schema'

module Tomograph
  class Action
    def initialize(content, path)
      @content = content['content']
      @source_path = path
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

    def to_hash
      @action ||= {
        'path' => path,
        'method' => method,
        'request' => request,
        'responses' => responses
      }
    end
  end
end
