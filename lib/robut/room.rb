# Handles connections and responses to different rooms. 
class Robut::Room < Robut::Presence

  # The MUC that wraps the Jabber Chat protocol.
  attr_accessor :muc

  # The room jid
  attr_accessor :name

  def initialize(connection, room_name)
    self.muc        = Jabber::MUC::SimpleMUCClient.new(connection.client)
    self.connection = connection
    self.name       = room_name
  end

  def join
    # Add the callback from messages that occur inside the room
    muc.on_message do |time, nick, message|
      plugins = Robut::Plugin.plugins.map { |p| p.new(self) }
      handle_message(plugins, time, nick, message)
    end

    muc.join(self.name + '/' + connection.config.nick)
  end

  # Send +message+ to the room we're currently connected to
  def reply(message, to)
    if to.present?
      unless to.kind_of?(Jabber::JID)
        to = find_jid_by_name(to)
      end

      muc.send(Jabber::Message.new(to, message))
    else
      muc.send(Jabber::Message.new(muc.room, message))
    end
  end
end
