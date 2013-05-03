require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../lib', __FILE__)

require './application'
require 'decisionmaker'
require 'weatherloader'
require 'rspec'
require 'rack/test'
require 'fakeredis/rspec'
require 'webmock/rspec'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

WebMock.disable_net_connect!

def fixture(filename)
  return '' if filename == ''
  file_path = File.expand_path(File.dirname(__FILE__) + '/fixtures/' + filename)
  File.read(file_path)
end
