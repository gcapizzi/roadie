require 'rubygems'
require 'bundler/setup'

RSpec.configure do |config|
  config.disable_monkey_patching!
end

# Setup SimpleCov

require 'simplecov'
SimpleCov.start if ENV['COVERAGE']
