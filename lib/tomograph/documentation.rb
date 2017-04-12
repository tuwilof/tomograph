module Tomograph
  class Documentation
    def initialize(apib_path: nil, drafter_yaml: nil, drafter_yaml_path: nil)
      if apib_path
        @hash = `drafter #{apib_path}`
      elsif drafter_yaml
        @hash = YAML.load(drafter_yaml)
      else
        @hash = YAML.load(File.read("#{Rails.root}/#{drafter_yaml_path}"))
      end
    end

    def to_hash
      @hash
    end
  end
end
