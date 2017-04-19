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

      def self.merge(actions)
        actions.group_by { |action| "#{action.method} #{action.path}" }.map do |_key, related_actions|
          new(
            path: related_actions.first.path.to_s,
            method: related_actions.first.method,
            request: related_actions.first.request,
            responses: related_actions.map(&:responses).flatten
          )
        end.flatten
      end

      def add_prefix(prefix)
        @path = Tomograph::Path.new("#{prefix}#{path}")
        self
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
