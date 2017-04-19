require 'spec_helper'
require 'tomograph/api_blueprint/yaml'

RSpec.describe Tomograph::ApiBlueprint::Yaml do
  it 'not raise exception' do
    allow_any_instance_of(Kernel).to receive(:`).and_return(double)
    expect{described_class.new(nil, '', nil)}.not_to raise_exception
  end
end
