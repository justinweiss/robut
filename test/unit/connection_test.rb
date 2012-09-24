require 'test_helper'
require 'robut/plugin/echo'

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

  def add_message_callback(code, reply_to)
    true
  end

  def join(path)
    true
  end
end

class RoomMock < Robut::Room

  def initialize(connection)
    @muc = ReplyMock.new
    @connection = connection
  end

end

class PMMock < Robut::PM

  def initialize(connection)
    @connection = connection
  end
end


class ConnectionTest < Test::Unit::TestCase

  def setup
    Robut::Plugin.plugins = [SimplePlugin]
    @connection = Robut::Connection.new({
        :jid => 'abc@def.com',
        :nick => "Test Robut",
        :mention_name => 'test'
      })
  end

  def test_end_to_end_message
    Robut::Plugin.plugins = [Robut::Plugin::Echo]
    justin = Jabber::JID.new('justin@example.com')
    @connection.roster = mock_roster(justin)
    room = RoomMock.new(@connection)
    room.handle_message(plugins(room), Time.now, 'Justin Weiss', '@test echo Test Message')
    message = room.muc.messages.first
    assert_equal(room.muc.room, message.to.to_s)
    assert_equal("Test Message", message.body)
  end

  def test_handle_message_delegates_to_plugin
    presence = Robut::Presence.new(@connection)
    plugins = plugins(presence)
    assert !plugins.first.run, "The plugin was not set up correctly."

    presence.handle_message(plugins, Time.now, 'Justin', 'Test Message')
    assert plugins.first.run, "The plugin's handle_message method should have been run"
  end

  def test_handle_message_from_person
    Robut::Plugin.plugins = [Robut::Plugin::Echo]
    sender = Jabber::JID.new('justin@example.com')
    @connection.client = ReplyMock.new
    pm = PMMock.new(@connection)

    pm.handle_message(plugins(pm, sender), Time.now, 'Justin', '@test echo Test Message')
    message = pm.connection.client.messages.first
    assert_equal(sender, message.to)
    assert_equal("Test Message", message.body)
  end

  def test_reply_directly_to_user
    Robut::Plugin.plugins = [ReplyToUserPlugin]
    @connection.client = ReplyMock.new
    justin = Jabber::JID.new('justin@example.com')
    @connection.roster = mock_roster(justin)
    pm = Robut::PM.new(@connection, justin)

    pm.handle_message(plugins(pm), Time.now, 'justin WEISS', 'Test Message')
    message = pm.connection.client.messages.first
    assert_equal(justin, message.to.to_s)
    assert_equal(:chat, message.type)
    assert_equal("Reply", message.body)
  end

  def test_reply_directly_to_room
    Robut::Plugin.plugins = [ReplyToRoomPlugin]
    sender = Jabber::JID.new('justin@example.com')
    room = RoomMock.new(@connection)

    room.handle_message(plugins(room, sender), Time.now, 'Justin', '@test echo Test Message')
    message = room.muc.messages.first
    assert_equal(room.muc.room, message.to.to_s)
    assert_equal("Reply", message.body)
  end

  private

  def plugins(presence, sender = nil)
    Robut::Plugin.plugins.map { |p| p.new(presence, sender) }
  end

  def mock_roster(jid)
    OpenStruct.new( :items => { jid => OpenStruct.new(:iname => "Justin Weiss") } )
  end

end
