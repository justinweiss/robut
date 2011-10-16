# Handles connections and responses to different rooms. 
class Robut::Room < Robut::Connection
  # The MUC that wraps the Jabber Chat protocol.
  attr_accessor :muc

  # The config of the master
  attr_accessor :config

  # Initializes the connection. If no +config+ is passed, it defaults
  # to the class_level +config+ instance variable.
  def initialize(client, config, room)
    self.muc = Jabber::MUC::SimpleMUCClient.new(client)
    self.config = config

    # Add the callback from messages that occur inside the room
    muc.on_message do |time, nick, message|
      plugins = Robut::Plugin.plugins.map { |p| p.new(self, nil) }
      handle_message(plugins, time, nick, message)
    end

    muc.join(room + '/' + config.nick)
  end

  # Send +message+ to the room we're currently connected to, or
  # directly to the person referenced by +to+. +to+ can be either a
  # jid or the string name of the person.
  def reply(message, to)
    muc.send(Jabber::Message.new(muc.room, message))
  end
end
