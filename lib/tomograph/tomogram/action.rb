require 'tomograph/path'

module Tomograph
  class Tomogram
    class Action
      attr_reader :path, :method, :request, :responses

      def initialize(path:, method:, request:, responses:)
        @path ||= Tomograph::Path.new(path)
        @method ||= method
        @request ||= request
        @responses ||= responses
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
          'request' => request,
          'responses' => responses
        }
      end
    end
  end
end
