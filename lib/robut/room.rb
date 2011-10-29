# Handles connections and responses to different rooms. 
class Robut::Room < Robut::Presence

  # The MUC that wraps the Jabber Chat protocol.
  attr_accessor :muc

  def initialize(connection, room)
    self.muc = Jabber::MUC::SimpleMUCClient.new(connection.client)
    self.connection = connection

    # Add the callback from messages that occur inside the room
    muc.on_message do |time, nick, message|
      plugins = Robut::Plugin.plugins.map { |p| p.new(self) }
      handle_message(plugins, time, nick, message)
    end

    muc.join(room + '/' + connection.config.nick)
  end

  # Send +message+ to the room we're currently connected to
  def reply(message, to)
    muc.send(Jabber::Message.new(muc.room, message))
  end
end
