require 'test_helper'
require 'robut/plugin/echo'
require 'robut/plugin/help'

class Robut::Plugin::PluginWithoutHelp
  include Robut::Plugin

  def usage
    super
  end
end

class Robut::Plugin::HelpTest < Test::Unit::TestCase

  def setup
    @connection = Robut::ConnectionMock.new
    @presence = Robut::PresenceMock.new(@connection)
    Robut::Plugin.plugins << Robut::Plugin::Echo
    Robut::Plugin.plugins << Robut::Plugin::Help
    @plugin = Robut::Plugin::Help.new(@presence)
  end

  def teardown
    Robut::Plugin.plugins = []
  end

  def test_help
    @plugin.handle(Time.now, "@justin", "@robut help")
    assert_equal [
      "Supported commands:",
      "@robut echo <message> - replies to the channel with <message>",
      "@robut help - displays this message",
    ], @plugin.reply_to.replies
  end

  def test_empty_help
    Robut::Plugin.plugins << Robut::Plugin::PluginWithoutHelp
    @plugin.handle(Time.now, "@justin", "@robut help")
    assert_equal [
      "Supported commands:",
      "@robut echo <message> - replies to the channel with <message>",
      "@robut help - displays this message",
    ], @plugin.reply_to.replies
  end
end
  
