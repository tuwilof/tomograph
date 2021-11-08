require 'tempfile'
require 'spec_helper'

RSpec.describe 'tomograph' do
  let(:input_path) { 'spec/fixtures/drafter_4/exe.yaml' }
  let(:options) {}
  let(:output_file) { Tempfile.new('') }
  let(:output_path) { output_file.path }

  subject(:run_tomograph) do
    system("bundle exec ./exe/tomograph #{options} '#{input_path}' '#{output_path}'")
  end

  def run_tests_with_file
    Tempfile.open('') do |_output|
      expect(run_tomograph).to be_truthy
      expect(IO.read(output_path)).to eq(IO.read(expected_path))
    end
  end

  context 'in default mode' do
    let(:expected_path) { 'spec/fixtures/tomogram/exe.json' }

    it 'produces correct json' do
      run_tests_with_file
    end
  end

  context 'with --exclude-description' do
    let(:expected_path) { 'spec/fixtures/tomogram/exe-exclude-description.json' }
    let(:options) { '--exclude-description' }

    it 'produces correct json' do
      run_tests_with_file
    end
  end

  def json_read(*path)
    JSON.parse(IO.read(File.join(*path)))
  end

  context 'with --split' do
    let(:options) { '--split' }
    let(:input_path) { 'spec/fixtures/drafter_4/exe-split.yaml' }
    let(:sessions_POST_path) { 'spec/fixtures/tomogram/exe-split-#sessions POST.json' }
    let(:sessions_DELETE_path) { 'spec/fixtures/tomogram/exe-split-#sessions#(id) DELETE.json' }
    let(:output_path) { Dir.mktmpdir }

    it 'produces correct json' do
      expect(run_tomograph).to be_truthy
      expect(json_read(output_path, '#sessions POST.json')).to eq(json_read(sessions_POST_path))
      expect(json_read(output_path, '#sessions#(id) DELETE.json')).to eq(json_read(sessions_DELETE_path))
      expect(Dir.entries(output_path).count).to eq(4)
    end

    after do
      FileUtils.remove_entry(output_path)
    end
  end
end
