module Tomograph
  class Request < Hash
    def find_responses(status:)
      self['responses'].find_all do |response|
        response['status'] == status.to_s
      end
    end
  end
end
