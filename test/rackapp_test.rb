require "test/unit"
require "rack/test"
require './lib/rackapp'
require 'erb'

class RackAppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    app = RackApp
    builder = Rack::Builder.new
    builder.run app
  end

  def test_root
    get '/'
    assert last_response.ok?
  end

  def test_start
    get '/start'
    follow_redirect!
    assert last_response.ok?
  end

  def test_submit_guess
    get '/submit_guess'
    follow_redirect!
    assert last_response.ok?
  end

  def test_hint
    get '/hint'
    follow_redirect!
    assert last_response.ok?
  end

  def test_save_result
    get '/save_result'
    follow_redirect!
    assert last_response.ok?
  end

  def test_cancel_save_result
    get '/cancel_save_result'
    follow_redirect!
    assert last_response.ok?
  end

  def test_statistics
    get '/statistics'
    assert last_response.ok?
  end

  def test_not_found
    get '/something_not_existing'
    assert_equal last_response.status, 404
  end
end
