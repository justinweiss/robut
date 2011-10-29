# Handles connections and responses to different rooms. 
class Robut::Room
  # The MUC that wraps the Jabber Chat protocol.
  attr_accessor :muc

  # The Robut::Connection that has all the connection info.
  attr_accessor :connection

  def initialize(connection, room)
    self.muc = Jabber::MUC::SimpleMUCClient.new(connection.client)
    self.connection = connection

    # Add the callback from messages that occur inside the room
    muc.on_message do |time, nick, message|
      plugins = Robut::Plugin.plugins.map { |p| p.new(connection, self) }
      handle_message(plugins, time, nick, message)
    end

    muc.join(room + '/' + connection.config.nick)
  end

  # Send +message+ to the room we're currently connected to
  def reply(message, to)
    muc.send(Jabber::Message.new(muc.room, message))
  end

    # Sends the chat message +message+ through +plugins+.
  def handle_message(plugins, time, nick, message)
    # ignore all messages sent by robut. If you really want robut to
    # reply to itself, you can use +fake_message+.
    return if nick == connection.config.nick

    plugins.each do |plugin|
      begin
        rsp = plugin.handle(time, nick, message)
        break if rsp == true
      rescue => e
        error = "UH OH! #{plugin.class.name} just crashed!"

        if nick
          reply(error, nick) # Connection#reply
        else
          reply(error)       # Room#reply
        end
        if connection.config.logger
          connection.config.logger.error e
          connection.config.logger.error e.backtrace.join("\n")
        end
      end
    end
  end

end
