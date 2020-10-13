lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tomograph/version'

Gem::Specification.new do |spec|
  spec.name           = 'tomograph'
  spec.version        = Tomograph::VERSION
  spec.authors        = ['d.efimov']
  spec.email          = ['d.efimov@fun-box.ru']

  spec.summary        = 'Convert API Blueprint to Tomogram'
  spec.description    = 'Convert API Blueprint to routes and JSON-Schemas'
  spec.homepage       = 'https://github.com/funbox/tomograph'
  spec.license        = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'byebug', '~> 11.1', '>= 11.1.1'
  spec.add_development_dependency 'rake', '>= 13.0.1'
  spec.add_development_dependency 'rspec', '~> 3.9', '>= 3.9.0'
  spec.add_development_dependency 'rubocop', '~> 0.81', '>= 0.81.0'
  spec.add_development_dependency 'simplecov', '~> 0.18', '>= 0.18.5'
  spec.required_ruby_version = '>= 2.4.0'
end
