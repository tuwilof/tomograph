require 'spec_helper'

RSpec.describe Tomograph do
  it 'makes settings' do
    Tomograph.configure do |config|
      config.documentation = 'doc/api.yaml'
    end
  end
end
