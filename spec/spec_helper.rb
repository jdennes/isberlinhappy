require 'simplecov'
SimpleCov.start

$:.unshift File.expand_path('..', __FILE__)

require './application'
require 'rspec'
require 'rack/test'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end