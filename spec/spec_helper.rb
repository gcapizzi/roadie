require 'rubygems'
require 'bundler/setup'

RSpec.configure do |config|
  config.expose_dsl_globally = false
end

# Setup SimpleCov

require 'simplecov'
SimpleCov.start if ENV['COVERAGE']
