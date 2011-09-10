require 'test_helper'

class SimplePlugin
  include Robut::Plugin
  attr_accessor :run

  def initialize(*args)
    super(*args)
    @run = false
  end

  def handle(*args)
    self.run = true
  end
end

class ReplyToUserPlugin
  include Robut::Plugin

  def initialize(*args)
    super(*args)
  end

  def handle(time, nick, message)
    reply("Reply", nick)
  end
end

class ReplyToRoomPlugin
  include Robut::Plugin

  def initialize(*args)
    super(*args)
  end

  def handle(time, nick, message)
    reply("Reply", :room)
  end
end

class ReplyMock
  attr_accessor :messages

  def initialize
    @messages = []
  end

  def send(message)
    @messages << message
  end

  def room
    "my_room@test.com"
  end
end

class ConnectionTest < Test::Unit::TestCase

  def setup
    Robut::Plugin.plugins = [SimplePlugin]
    @connection = Robut::Connection.new({
        :jid => 'abc@def.com',
        :nick => "Test Robut"
      })
  end

  def test_end_to_end_message
    Robut::Plugin.plugins = [Robut::Plugin::Echo]
    @connection.muc = ReplyMock.new
    @connection.handle_message(plugins(@connection), Time.now, 'Justin', '@test echo Test Message')
    message = @connection.muc.messages.first
    assert_equal(@connection.muc.room, message.to.to_s)
    assert_equal("Test Message", message.body)
  end

  def test_handle_message_delegates_to_plugin
    plugins = plugins(@connection)
    assert !plugins.first.run, "The plugin was not set up correctly."
    @connection.handle_message(plugins, Time.now, 'Justin', 'Test Message')
    assert plugins.first.run, "The plugin's handle_message method should have been run"
  end

  def test_handle_message_from_person
    Robut::Plugin.plugins = [Robut::Plugin::Echo]
    sender = Jabber::JID.new('justin@example.com')
    @connection.client = ReplyMock.new
    @connection.handle_message(plugins(@connection, sender), Time.now, 'Justin', '@test echo Test Message')
    message = @connection.client.messages.first
    assert_equal(sender, message.to)
    assert_equal("Test Message", message.body)
  end

  def test_reply_directly_to_user
    Robut::Plugin.plugins = [ReplyToUserPlugin]
    @connection.client = ReplyMock.new
    justin = Jabber::JID.new('justin@example.com')
    @connection.roster = OpenStruct.new({
    :items => {
      justin => OpenStruct.new({
        :iname => "Justin Weiss"
          })
        }
    })

    @connection.handle_message(plugins(@connection), Time.now, 'justin WEISS', 'Test Message')
    message = @connection.client.messages.first
    assert_equal(justin, message.to.to_s)
    assert_equal(:chat, message.type)
    assert_equal("Reply", message.body)
  end

  def test_reply_directly_to_room
    Robut::Plugin.plugins = [ReplyToRoomPlugin]
    sender = Jabber::JID.new('justin@example.com')
    @connection.muc = ReplyMock.new
    @connection.handle_message(plugins(@connection, sender), Time.now, 'Justin', '@test echo Test Message')
    message = @connection.muc.messages.first
    assert_equal(@connection.muc.room, message.to.to_s)
    assert_equal("Reply", message.body)
  end

  private

  def plugins(connection, sender = nil)
    Robut::Plugin.plugins.map { |p| p.new(connection, sender) }
  end

end
