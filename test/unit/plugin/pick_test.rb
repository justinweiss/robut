require 'test_helper'
require 'robut/plugin/pick'
require 'mocha/setup'

class Robut::Plugin::PickTest < Test::Unit::TestCase

  def setup
    @connection = Robut::ConnectionMock.new
    @presence = Robut::PresenceMock.new(@connection)
    @plugin = Robut::Plugin::Pick.new(@presence)
  end

  def test_replies_with_correct_response
    @plugin.stubs(:random).returns(0)
    @plugin.handle(Time.now, "@john", "@robut pick a, b, c")
    assert_equal ["And the winner is... a"], @plugin.reply_to.replies
  end

  def test_does_nothing_when_no_options_are_given
    @plugin.handle(Time.now, "@john", "@robut pick")
    assert @plugin.reply_to.replies.empty?
  end

  def test_replies_only_option_if_given_one_options
    @plugin.handle(Time.now, "@john", "@robut pick a")
    assert_equal ["And the winner is... a"], @plugin.reply_to.replies
  end

  def test_handles_spaces
    @plugin.stubs(:random).returns(1)
    @plugin.handle(Time.now, "@john", "@robut pick this is the first option, this is the second option, this is the third option")
    assert_equal ["And the winner is... this is the second option"], @plugin.reply_to.replies
  end

end
