require 'rubygems'
require 'bundler/setup'

# Setup SimpleCov

require 'simplecov'
SimpleCov.start if ENV['COVERAGE']
