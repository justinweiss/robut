require 'test_helper'
require 'robut/plugin/later'

class Robut::Plugin::LaterTest < Test::Unit::TestCase

  def setup
    @connection = Robut::ConnectionMock.new
    @presence = Robut::PresenceMock.new(@connection)
    @plugin = Robut::Plugin::Later.new(@presence)
    @plugin.instance_eval do
      def threader; yield; end # no threads
      def sleep(*prms); end # just skip the whole sleeping part
    end
  end

  def test_replies_with_minutes
    @plugin.handle(Time.now, "@john", "@robut in 0 minutes msg me")
    assert_equal ["Ok, see you in 0 minutes"], @plugin.reply_to.replies
    message = @plugin.reply_to.messages.first
    assert message
    assert_equal message[1], "@john"
    assert_equal message[2], "@robut msg me"
  end

  def test_replies_with_sec
    @plugin.handle(Time.now, "@john", "@robut in 1 sec msg me")
    assert_equal ["Ok, see you in 1 sec"], @plugin.reply_to.replies
  end
  
  def test_replies_with_hr
    @plugin.handle(Time.now, "@john", "@robut in 1 hr msg me")
    assert_equal ["Ok, see you in 1 hr"], @plugin.reply_to.replies
  end

  def test_replies_with_hrs
    @plugin.handle(Time.now, "@john", "@robut in 2 hrs msg me")
    assert_equal ["Ok, see you in 2 hrs"], @plugin.reply_to.replies
  end
  
end
