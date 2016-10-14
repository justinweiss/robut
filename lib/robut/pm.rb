class Robut::PM < Robut::Presence

  def initialize(connection)
    # Add the callback from direct messages. Turns out the
    # on_private_message callback doesn't do what it sounds like, so I
    # have to go a little deeper into xmpp4r to get this working.
    self.connection = connection
    add_invite_callback(100)
    add_message_callback(200)
  end

  def reply(message, to)
    unless to.kind_of?(Jabber::JID)
      to = find_jid_by_name(to)
    end

    msg = Jabber::Message.new(to, message)
    msg.type = :chat
    connection.client.send(msg)
  end

  private

  def is_invite?(message)
    puts message.to_s
    message.type.nil? && message.x.elements["//invite"]
  end

  def add_invite_callback(priority)
    connection.client.add_message_callback(100, self) do |message|
      connection.join_room(message.from.node) if is_invite?(message)
    end
  end

  def add_message_callback(priority)
    connection.client.add_message_callback(priority, self) do |message|
      from_room = connection.rooms.any? {|room| room.muc.from_room?(message.from)}
      if !from_room && message.type == :chat && message.body
        time = Time.now # TODO: get real timestamp? Doesn't seem like
                        # jabber gives it to us
        sender_jid = message.from
        plugins = Robut::Plugin.plugins.map { |p| p.new(self, sender_jid) }
        handle_message(plugins, time, connection.roster[sender_jid].iname, message.body)
        true
      else
        false
      end
    end
  end

  # Find a jid in the roster with the given name, case-insensitively
  def find_jid_by_name(name)
    name = name.downcase
    connection.roster.items.detect {|jid, item| item.iname.downcase == name}.first
  end
end
