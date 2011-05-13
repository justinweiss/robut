require 'test_helper'
require 'robut/plugin/echo'

class Robut::Plugin::EchoTest < Test::Unit::TestCase

  def setup
    @connection = Robut::ConnectionMock.new
    @plugin = Robut::Plugin::Echo.new(@connection)
  end

  def test_replies_with_this
    @plugin.handle(Time.now, "@john", "@robut echo this")
    assert_equal ["this"], @plugin.connection.replies
  end

  def test_replies_with_nicks
    @plugin.handle(Time.now, "@john", "@robut echo @justin look over here!")
    assert_equal ["@justin look over here!"], @plugin.connection.replies
  end
  
  def test_doesnt_reply_with_empty
    @plugin.handle(Time.now, "@john", "@robut echo")
    assert_equal [], @plugin.connection.replies    
  end
  
end
