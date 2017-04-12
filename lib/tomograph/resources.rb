module Tomograph
  class Resources
    def initialize(documentation)
      @resources = documentation['content'][0]['content'].find_all do |resource|
        resource['element'] != 'copy' && # Element is a human readable text
          resource['meta']['classes'][0] == 'resourceGroup' # skip Data Structures
      end
    end

    def to_hash
      @resources
    end
  end
end
