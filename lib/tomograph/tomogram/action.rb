require 'tomograph/path'

module Tomograph
  class Tomogram
    class Action
      def initialize(path:, method:, request:, responses:)
        @path ||= Tomograph::Path.new(path)
        @method ||= method
        @request ||= request
        @responses ||= responses
      end

      def path
        @path
      end

      def method
        @method
      end

      def request
        @request
      end

      def responses
        @responses
      end

      def add_prefix(prefix)
        @path = Tomograph::Path.new("#{prefix}#{path}")
        self
      end

      def add_responses(re_responses)
        @responses = re_responses
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
