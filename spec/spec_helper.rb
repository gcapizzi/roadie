require 'rubygems'
require 'bundler/setup'

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
    mocks.verify_doubled_constant_names = true
  end
end

# Helpers

def req(method, path)
  Rack::MockRequest.env_for(path, method: method)
end
