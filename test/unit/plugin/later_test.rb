require 'test_helper'
require 'robut/plugin/later'

class Robut::Plugin::LaterTest < Test::Unit::TestCase

  def setup
    @connection = Robut::ConnectionMock.new
    @plugin = Robut::Plugin::Later.new(@connection)
    @plugin.instance_eval do
      def threader; yield; end # no threads
      def sleep(*prms); end # just skip the whole sleeping part
    end
  end

  def test_replies_wih_minutes
    @plugin.handle(Time.now, "@john", "@robut in 0 minutes msg me")
    assert_equal ["Ok, see you in 0 minutes"], @plugin.connection.replies
    message = @plugin.connection.messages.first
    assert message
    assert_equal message[1], "@john"
    assert_equal message[2], "msg me"
  end

  def test_replies_wih_sec
    @plugin.handle(Time.now, "@john", "@robut in 1 sec msg me")
    assert_equal ["Ok, see you in 1 sec"], @plugin.connection.replies
  end
  
  def test_replies_wih_hr
    @plugin.handle(Time.now, "@john", "@robut in 1 hr msg me")
    assert_equal ["Ok, see you in 1 hr"], @plugin.connection.replies
  end

  def test_replies_wih_hrs
    @plugin.handle(Time.now, "@john", "@robut in 2 hrs msg me")
    assert_equal ["Ok, see you in 2 hrs"], @plugin.connection.replies
  end
  
end
