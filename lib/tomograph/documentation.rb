module Tomograph
  class Documentation
    def initialize(apib_path: nil, drafter_yaml: nil, drafter_yaml_path: nil)
      if apib_path
        @documentation = `drafter #{apib_path}`
      elsif drafter_yaml
        @documentation = YAML.load(drafter_yaml)
      else
        @documentation = YAML.load(File.read("#{Rails.root}/#{drafter_yaml_path}"))
      end
    end

    def groups
      @groups ||= @documentation['content'][0]['content'].map do |group|
        if group['element'] != 'copy' && # Element is a human readable text
          group['meta']['classes'][0] == 'resourceGroup' # skip Data Structures
          group['content'].find_all do |resources|
            resources['element'] != 'copy' # Element is a human readable text
          end
        end
      end.compact
    end
  end
end
