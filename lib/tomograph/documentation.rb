module Tomograph
  class Documentation
    def initialize(apib_path: nil, drafter_yaml: nil, drafter_yaml_path: nil)
      @documentation = if apib_path
                         `drafter #{apib_path}`
                       elsif drafter_yaml
                         YAML.safe_load(drafter_yaml)
                       else
                         YAML.safe_load(File.read("#{Rails.root}/#{drafter_yaml_path}"))
                       end
    end

    def to_hash
      @documentation
    end
  end
end
