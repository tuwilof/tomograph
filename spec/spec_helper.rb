require 'rspec'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'
SimpleCov.start

require 'yaml'
require 'multi_json'
require 'byebug'
require 'tomograph'

class Rails
end
