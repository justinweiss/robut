require 'test_helper'
require 'robut/plugin/ping'

class Robut::Plugin::PingTest < Test::Unit::TestCase

  def setup
    @connection = Robut::ConnectionMock.new
    @presence = Robut::PresenceMock.new(@connection)
    @plugin = Robut::Plugin::Ping.new(@presence)
  end

  def test_replies_wih_pong
    @plugin.handle(Time.now, "@john", "@robut ping")
    assert_equal ["pong"], @plugin.reply_to.replies
  end

  def test_replies_wih_sec
    @plugin.handle(Time.now, "@john", "@robut ping pong")
    assert_equal [], @plugin.reply_to.replies
  end
  
end
