require 'simplecov'
SimpleCov.start

$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../lib', __FILE__)

require './application'
require 'decisionmaker'
require 'weatherloader'
require 'rspec'
require 'rack/test'
require 'fakeredis'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end