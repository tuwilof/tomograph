require 'tempfile'
require 'spec_helper'

RSpec.describe 'tomograph' do
  def run_tests
    Tempfile.open('') do |output|
      expect(system("bundle exec ./exe/tomograph #{options} '#{input_path}' '#{output.path}'")).to be_truthy
      expect(IO.read(output.path)).to eq(IO.read(expected_path))
    end
  end

  let(:input_path) { 'spec/fixtures/exe.yaml' }
  let(:options) {}

  context 'in default mode' do
    let(:expected_path) { 'spec/fixtures/exe.json' }

    it 'produces correct json' do
      run_tests
    end
  end

  context 'with --exclude-description' do
    let(:expected_path) { 'spec/fixtures/exe-exclude-description.json' }
    let(:options) { '--exclude-description' }

    it 'produces correct json' do
      run_tests
    end
  end
end
