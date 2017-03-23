module Tomograph
  class Configuration
    attr_accessor :documentation,
                  :prefix,
                  :drafter_yaml

    def initialize
      @prefix = ''
    end
  end
end
