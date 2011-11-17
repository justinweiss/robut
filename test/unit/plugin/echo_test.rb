require 'test_helper'
require 'robut/plugin/echo'

class Robut::Plugin::EchoTest < Test::Unit::TestCase

  def setup
    @connection = Robut::ConnectionMock.new
    @presence = Robut::PresenceMock.new(@connection)
    @plugin = Robut::Plugin::Echo.new(@presence)
  end

  def test_replies_with_this
    @plugin.handle(Time.now, "@john", "@robut echo this")
    assert_equal ["this"], @plugin.reply_to.replies
  end

  def test_replies_with_nicks
    @plugin.handle(Time.now, "@john", "@robut echo @justin look over here!")
    assert_equal ["@justin look over here!"], @plugin.reply_to.replies
  end
  
  def test_doesnt_reply_with_empty
    @plugin.handle(Time.now, "@john", "@robut echo")
    assert_equal [], @plugin.reply_to.replies
  end
  
end
