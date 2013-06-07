require 'test_helper'
require 'rack/test'

class WebTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Robut::Web
  end

  def setup
    app.set :show_exceptions, false
    app.set :raise_errors, true
    app.set :connection, connection
  end

  def test_root
    get '/'

    assert last_response.ok?
  end

  def test_say
    app.class_eval do
      get '/test_say' do
        say "Hello", nil
        halt 200
      end
    end

    get '/test_say'

    assert_equal messages.first, ["Hello", nil]
  end

private

  def messages
    connection.messages
  end

  def connection
    @connection ||= Robut::ConnectionMock.new.connect
  end

end
