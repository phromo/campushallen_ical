require 'rubygems'
require "test/unit"
require 'rack/test'

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib') unless $LOAD_PATH.include?(File.dirname(__FILE__) + '/../lib')
require 'phromo_campushallen/webapp'

class WebTest < Test::Unit::TestCase
  include Rack::Test::Methods

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def app
    Sinatra::Application
  end

  # Fake test
  def test_fail
    get '/hi'
    puts last_response.body
    assert_equal 'Hello World', last_response.body
  end
end