require 'tomograph/path'
require 'tomograph/request/json_schema'
require 'tomograph/response/json_schema'

module Tomograph
  class Action
    def initialize(content, path)
      return if content['element'] == 'copy' # Element is a human readable text

      @action = action_to_hash(content['content'], path)
    end

    def action_to_hash(actions, path)
      {
        'path' => "#{@prefix}#{Tomograph::Path.new(path)}",
        'method' => actions.first['attributes']['method'],
        'request' => Tomograph::Request::JsonSchema.new(actions).to_hash,
        'responses' => responses(actions)
      }
    end

    def responses(actions)
      actions.select {|response| Tomograph::Response::JsonSchema.valid?(response)}.map do |response|
        Tomograph::Response::JsonSchema.new(response).to_hash
      end
    end

    def to_hash
      @action
    end
  end
end
