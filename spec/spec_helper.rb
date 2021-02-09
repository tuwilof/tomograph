require 'rspec'
require 'rspec/support/object_formatter'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'
#SimpleCov.start

require 'byebug'
require 'tomograph'
require 'json-schema'

# Raise limit until string diff is implemented
# https://github.com/rspec/rspec-core/issues/2535
RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = 1000

