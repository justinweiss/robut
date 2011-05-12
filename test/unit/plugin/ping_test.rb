require 'test_helper'
require 'robut/plugin/ping'

class Robut::Plugin::PingTest < Test::Unit::TestCase

  def setup
    @connection = Robut::ConnectionMock.new
    @plugin = Robut::Plugin::Ping.new(@connection)
  end

  def test_replies_wih_pong
    @plugin.handle(Time.now, "@john", "@robut ping")
    assert_equal ["pong"], @plugin.connection.replies
  end

  def test_replies_wih_sec
    @plugin.handle(Time.now, "@john", "@robut ping pong")
    assert_equal [], @plugin.connection.replies
  end
  
end
