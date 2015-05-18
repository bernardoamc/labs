ENV['RACK_ENV'] = 'test'

require_relative File.join('..', 'service')
require_relative File.join('..', 'client')

require 'minitest/autorun'
MiniTest::Spec.send :include, Rack::Test::Methods
