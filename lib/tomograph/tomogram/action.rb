require 'tomograph/path'

module Tomograph
  class Tomogram
    class Action
      attr_reader :path, :method, :content_type, :requests, :responses, :resource

      def initialize(path:, method:, content_type:, requests:, responses:, resource:)
        @path ||= Tomograph::Path.new(path)
        @method ||= method
        @content_type ||= content_type
        @requests ||= requests
        @responses ||= responses
        @resource ||= resource
      end

      def find_responses(status:)
        to_hash['responses'].find_all do |response|
          response['status'] == status.to_s
        end
      end

      def to_hash
        @action ||= {
          'path' => path,
          'method' => method,
          'content-type' => content_type,
          'requests' => requests,
          'responses' => responses,
          'resource' => resource
        }
      end
    end
  end
end
