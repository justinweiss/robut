require 'test_helper'
require 'robut/plugin/echo'

class MucMock
  attr_accessor :messages, :room

  def initialize
    @messages = []
    @room = ''
  end

  def join(room)
    @room = room
  end

  def send(message)
    @messages << message
  end

  def on_message(*args, &block)
    if block_given?
      @message_block = block
    else
      @message_block.call(args)
    end
  end
end

class RoomTest < Test::Unit::TestCase
  def setup
    Robut::Plugin.plugins = [Robut::Plugin::Echo]
    connection = Robut::ConnectionMock.new(OpenStruct.new(:nick => 'Dodo'))
    @room = Robut::Room.new(connection, 'fake_room')
  end

  def test_room_receives_correct_message
    message = 'Huzzah!'
    @room.muc = MucMock.new
    @room.join

    @room.muc.on_message(Time.now, "Art Vandelay", "@dodo echo #{message}")
    assert_equal @room.muc.messages.first.body, message
  end

  def test_joining_the_right_room
    @room.muc = MucMock.new
    @room.join

    assert_equal @room.muc.room, "#{@room.name}/#{@room.connection.config.nick}"
  end

  def test_sends_pm_from_room_context
    @room.muc = MucMock.new
    @room.join

    id = Jabber::JID.new

    @room.reply("My message", id)

    assert id  ==  @room.muc.messages.first.to.domain
  end
end
