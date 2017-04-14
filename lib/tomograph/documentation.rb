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

    def to_hash
      @documentation
    end
  end
end
