class Robut::PM < Robut::Presence

  def initialize(connection, rooms)
    # Add the callback from direct messages. Turns out the
    # on_private_message callback doesn't do what it sounds like, so I
    # have to go a little deeper into xmpp4r to get this working.
    self.connection = connection
    connection.client.add_message_callback(200, self) do |message|
      from_room = rooms.any? {|room| room.muc.from_room?(message.from)}
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

  def reply(message, to)
    unless to.kind_of?(Jabber::JID)
      to = find_jid_by_name(to)
    end

    msg = Jabber::Message.new(to, message)
    msg.type = :chat
    connection.client.send(msg)
  end

  private

  # Find a jid in the roster with the given name, case-insensitively
  def find_jid_by_name(name)
    name = name.downcase
    connection.roster.items.detect {|jid, item| item.iname.downcase == name}.first
  end
end
