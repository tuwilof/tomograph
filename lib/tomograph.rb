require 'tomograph/tomogram'
require 'tomograph/configuration'

module Tomograph
  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end
end
