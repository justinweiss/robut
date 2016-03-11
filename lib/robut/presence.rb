class Robut::Presence

  # The Robut::Connection that has all the connection info.
  attr_accessor :connection

  def initialize(connection)
    self.connection = connection
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

  private

  # Find a jid in the roster with the given name, case-insensitively
  def find_jid_by_name(name)
    name = name.downcase
    connection.roster.items.detect {|jid, item| item.iname.downcase == name}.first
  end

end
