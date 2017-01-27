module Tomograph
  class Configuration
    attr_accessor :documentation,
                  :prefix

    def initialize
      @prefix = ''
    end
  end
end
