require 'rake'
require 'tempfile'
require 'spec_helper'

describe 'tomograph', type: :task do
  let(:input_path) { 'spec/fixtures/drafter_4/exe.yaml' }
  let(:options) { }
  let(:output_file) { Tempfile.new('') }
  let(:output_path) { output_file.path }

  subject(:rake_task) { Rake.application[:tomograph] }

  before(:all) do
    Rake.application.init
    Rake.application.load_rakefile
  end

  before { rake_task.reenable }

  def run_tests_with_file
    Tempfile.open('') do |output|
      expect(rake_task.invoke).to be_truthy
      expect(IO.read(output_path)).to eq(IO.read(expected_path))
    end
  end

  context 'in default mode' do
    let(:expected_path) { 'spec/fixtures/tomogram/exe.json' }

    before do
      argv = ["tomograph", "--", "--input=#{input_path}", "--output=#{output_path}"]
      stub_const("ARGV", argv)
    end

    it 'produces correct json' do
      run_tests_with_file
    end
  end

  context 'with --exclude-description' do
    let(:expected_path) { 'spec/fixtures/tomogram/exe-exclude-description.json' }
    let(:options) { '--exclude-description' }

    before do
      argv = ["tomograph", "--", options, "--input=#{input_path}", "--output=#{output_path}"]
      stub_const("ARGV", argv)
    end

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

    before do
      argv = ["tomograph", "--", options, "--input=#{input_path}", "--output=#{output_path}"]
      stub_const("ARGV", argv)
    end

    it 'produces correct json' do
      expect(rake_task.invoke(options, input_path, output_path)).to be_truthy
      expect(json_read(output_path, '#sessions POST.json')).to eq(json_read(sessions_POST_path))
      expect(json_read(output_path, '#sessions#(id) DELETE.json')).to eq(json_read(sessions_DELETE_path))
      expect(Dir.entries(output_path).count).to eq(4)
    end

    after do
      FileUtils.remove_entry(output_path)
    end
  end
end
