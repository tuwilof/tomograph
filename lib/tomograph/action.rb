require 'tomograph/path'
require 'tomograph/request/json_schema'
require 'tomograph/response/json_schema'

module Tomograph
  class Action
    def initialize(content, source_path, prefix)
      @content = content['content']
      @source_path = source_path
      @prefix = prefix
    end

    def path
      @path ||= "#{@prefix}#{Tomograph::Path.new(@source_path)}"
    end

    def method
      @method ||= @content.first['attributes']['method']
    end

    def request
      @request ||= Tomograph::Request::JsonSchema.new(@content).to_hash
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

    def match_path(find_path)
      return @regexp =~ find_path if @regexp

      str = Regexp.escape(path)
      str = str.gsub(/\\{\w+\\}/, '[^&=\/]+')
      str = "\\A#{ str }\\z"
      @regexp = Regexp.new(str)
      @regexp =~ find_path
    end
  end
end
