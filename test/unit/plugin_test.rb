require 'test_helper'

class Robut::PluginTest < Test::Unit::TestCase

  class HandrolledStubPlugin
    include Robut::Plugin

    match /^message sent to robut with anchor (\w+)/, :sent_to_me => true do |word|
      reply word
    end

    match /^another message sent to robut with anchor (\w+)/, :sent_to_me => true do |word|
      reply word
    end

    desc "stop matcher - stop matching messages"
    match /stop matcher/ do
      true
    end

    match /stop matcher b/ do
      reply "fail."
    end
  end

  def setup
    @plugin = HandrolledStubPlugin.new(
      Robut::PresenceMock.new(
        Robut::ConnectionMock
      )
    )
  end

  def test_sent_to_me_match
    @plugin.handle(Time.now, "@john", "@robut message sent to robut with anchor pass")
    assert_equal ["pass"], @plugin.reply_to.replies
  end

  def test_match_other_message_sent_to_me
    @plugin.handle(Time.now, "@john", "@robut another message sent to robut with anchor pass")
    assert_equal ["pass"], @plugin.reply_to.replies
  end

  def test_no_match_if_not_sent_to_me
    @plugin.handle(Time.now, "@john", "message sent to robut with anchor pass")
    assert_equal [], @plugin.reply_to.replies
  end

  def test_returning_true_stops_matching
    @plugin.handle(Time.now, "@john", "stop matcher b")
    assert_equal [], @plugin.reply_to.replies
  end

  def test_set_description
    assert_equal ["stop matcher - stop matching messages"], @plugin.usage
  end

  def test_sent_to_me?
    assert @plugin.sent_to_me?("@Robut hello there")
    assert !@plugin.sent_to_me?("@Robuto hello there")
    assert !@plugin.sent_to_me?("@David hello there")
    assert @plugin.sent_to_me?("this is a @Robut message")
    assert @plugin.sent_to_me?("this is a message to @robut")
    assert !@plugin.sent_to_me?("this is a message to@robut")
  end

  def test_without_nick_robut_do_this
    assert_equal "do this", @plugin.without_nick("@robut do this")
  end

  def test_without_nick_do_this_robut
    assert_equal "do this @robut", @plugin.without_nick("do this @robut")
  end

  def test_sent_to_me_without_mention_configuration_option
    setup_connection_without_mention_name
    assert @plugin.sent_to_me?("@RobutTRobot hello there"), "sent_to_me? should match the standard HipChat mention format"
    assert !@plugin.sent_to_me?("@Robut hello there"), "sent_to_me? should not match @robut if we don't have a mention name set"
  end

  private

  def setup_connection_without_mention_name
    @plugin = HandrolledStubPlugin.new(
      Robut::PresenceMock.new(
        Robut::ConnectionMock.new(OpenStruct.new(:nick => 'Robut t. Robot'))
      )
    )
  end

end
