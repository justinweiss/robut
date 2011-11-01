require 'test_helper'
require 'robut/plugin/say'

class Robut::Plugin::SayTest < Test::Unit::TestCase

  def setup
    @connection = Robut::ConnectionMock.new
    @presence = Robut::PresenceMock.new(@connection)
    @plugin = Robut::Plugin::Say.new(@presence)
    @plugin.instance_eval do
      # Stub out system
      def system(c); system_calls << c; end
      def system_calls; @system_calls ||= []; end;
    end
  end

  def test_says_stuff
    @plugin.handle(Time.now, "@john", "@robut say stuff")
    assert_equal [], @plugin.reply_to.replies # shouldn't reply to the chat room
    assert_equal ["say stuff"], @plugin.system_calls
  end
  
  def test_doesnt_say_stuff
    @plugin.handle(Time.now, "@john", "@robut ok don't say stuff")
    assert_equal [], @plugin.reply_to.replies
    assert_equal [], @plugin.system_calls
  end
  
  def test_strips_bad_chars
    @plugin.handle(Time.now, "@john", "@robut say it's time for $%@ more_test 123 p\"")
    assert_equal ["say its time for more test 123 p"], @plugin.system_calls
  end
  
end
