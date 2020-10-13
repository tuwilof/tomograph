require 'optparse'
require 'fileutils'
require 'tomograph'

desc 'Converts API Blueprint to JSON Schema'
task :tomograph do
  options = {}
  option_parser = OptionParser.new do |opts|
    opts.banner = "Usage: rake tomograph -- --options, --input, --output'"
    opts.on('--drafter[DRAFTER_VERSION]', 'Choose drafter version: crafter or 4. Default: use drafter v.4.') { |n| options['drafter'] = n }
    opts.on('--exclude-description', 'Exclude "description" keys.') { |n| options['exclude-description'] = n }
    opts.on('--split', 'Split output into files by method.') { |n| options['split'] = n }
    opts.on('--input[FILE_PATH]', 'path/to/doc.yaml (API Elements)') { |n| options['input'] = n }
    opts.on('--output[FILE_PATH]', 'path/to/doc.json or path/to/dir if --split is used.') { |n| options['output'] = n }
    opts.on('-h', '--help', 'Prints this help') { puts opts;exit }
  end
  
  args = option_parser.order!(ARGV) {}
  option_parser.parse!(args)

  def prune!(obj, unwanted_key)
    if obj.is_a?(Hash)
      obj.delete(unwanted_key)
      obj.each_value { |value| prune!(value, unwanted_key) }
    elsif obj.is_a?(Array)
      obj.each { |value| prune!(value, unwanted_key) }
    end
  end

  def fetch_format(input)
    return :yaml if ['.yaml', '.yml'].include?(File.extname(input).downcase)

    fail 'Unsupported input file extension!'
  end

  def choose_drafter(opt_parser)
    case opt_parser
    when 'crafter'
      :crafter
    when '4'
      :drafter_4
    when nil
      :drafter_4
    else
      fail 'Unsupported drafter version!'
    end
  end

  def write_split_json(actions, output)
    FileUtils.mkdir_p(output)
    actions.clone.each do |action|
      json_name = "#{action.delete("path").to_s} #{action.delete("method")}.json"
      [['/', '#'],
       ['{', '('],
       ['}', ')']].each do |pattern, replacement|
        json_name.gsub!(pattern, replacement)
      end
      write_json(action, File.join(output, json_name))
    end
  end
  
  def write_json(obj, path)
    json = JSON.pretty_generate(obj)
    File.open(path, 'w') do |file|
      file.write(json)
    end
  end

  format = fetch_format(options['input'])
  version = choose_drafter(options['drafter'])
  format_key = {
                  crafter:   :crafter_yaml_path,
                  drafter_4: :drafter_yaml_path
               }[version]

  tomogram = Tomograph::Tomogram.new(format_key => options['input'])
  actions = tomogram.to_a.map(&:to_hash)

  prune!(actions, 'description') if options['exclude-description']

  if options['split']
    write_split_json(actions, options['output'])
  else
    write_json(actions, options['output'])
  end
  0
end
