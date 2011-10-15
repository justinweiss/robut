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
  def reply(message, to = nil)
    if to
      unless to.kind_of?(Jabber::JID)
        to = find_jid_by_name(to)
      end

      msg = Jabber::Message.new(to || muc.room, message)
      msg.type = :chat
      client.send(msg)
    else
      muc.send(Jabber::Message.new(muc.room, message))
    end
  end

  # Sends the chat message +message+ through +plugins+.
  def handle_message(plugins, time, nick, message)
    # ignore all messages sent by robut. If you really want robut to
    # reply to itself, you can use +fake_message+.
    return if nick == config.nick
    
    plugins.each do |plugin|
      begin
        rsp = plugin.handle(time, nick, message)
        break if rsp == true
      rescue => e
        reply("UH OH! #{plugin.class.name} just crashed!")
        if config.logger
          config.logger.error e
          config.logger.error e.backtrace.join("\n")
        end
      end
    end
  end

  private

  # Find a jid in the roster with the given name, case-insensitively
  def find_jid_by_name(name)
    name = name.downcase
    roster.items.detect {|jid, item| item.iname.downcase == name}.first
  end
end
