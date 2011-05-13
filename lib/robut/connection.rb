require 'xmpp4r'
require 'xmpp4r/muc/helper/simplemucclient'
require 'xmpp4r/roster/helper/roster'
require 'ostruct'

# Handles opening a connection to the HipChat server, and feeds all
# messages through our Robut::Plugin list.
class Robut::Connection
  
  # The configuration used by the Robut connection.
  #
  # Parameters:
  #
  # [+jid+, +password+, +nick+] The HipChat credentials given on
  #                             https://www.hipchat.com/account/xmpp
  #
  # [+room+] The chat room to join, in the format <tt>jabber_name</tt>@<tt>conference_server</tt>
  #
  # [+logger+] a logger instance to use for debug output.
  attr_accessor :config

  # The Jabber::Client that's connected to the HipChat server.
  attr_accessor :client

  # The MUC that wraps the Jabber Chat protocol.
  attr_accessor :muc

  # The storage instance that's available to plugins
  attr_accessor :store

  # The roster of currently available people
  attr_accessor :roster

  class << self
    # Class-level config. This is set by the +configure+ class method,
    # and is used if no configuration is passed to the +initialize+
    # method.
    attr_accessor :config
  end

  # Configures the connection at the class level. When the +robut+ bin
  # file is loaded, it evals the file referenced by the first
  # command-line parameter. This file can configure the connection
  # instance later created by +robut+ by setting parameters in the
  # Robut::Connection.configure block.
  def self.configure
    self.config = OpenStruct.new
    yield config
    self.config = OpenStruct.new(config) if config.kind_of?(Hash)
  end

  # Initializes the connection. If no +config+ is passed, it defaults
  # to the class_level +config+ instance variable.
  def initialize(_config = nil)
    self.config = _config || self.class.config
    
    self.client = Jabber::Client.new(self.config.jid)
    self.muc = Jabber::MUC::SimpleMUCClient.new(client)
    self.store = self.config.store || Robut::Storage::HashStore # default to in-memory store only

    if self.config.logger
      Jabber.logger = self.config.logger
      Jabber.debug = true
    end
  end

  # Find a jid in the roster with the given name, case-insensitively
  def find_jid_by_name(name)
    name = name.downcase
    roster.items.detect {|jid, item| item.iname.downcase == name}.first
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
    plugins.each do |plugin|
      begin
        rsp = plugin.handle(time, nick, message)
        break if rsp == true
      rescue => e
        reply("I just pooped myself trying to run #{plugin.class.name}. AWK-WAAAARD!")
        if config.logger
          config.logger.error e
          config.logger.error e.backtrace
        end
      end
    end
  end

  # Connects to the specified room with the given credentials, and
  # enters an infinite loop. Any messages sent to the room will pass
  # through all the included plugins.
  def connect
    client.connect
    client.auth(config.password)
    client.send(Jabber::Presence.new.set_type(:available))

    self.roster = Jabber::Roster::Helper.new(client)
    roster.wait_for_roster
    
    muc.on_message do |time, nick, message|
      plugins = Robut::Plugin.plugins.map { |p| p.new(self, nil) }
      handle_message(plugins, time, nick, message)
    end

    client.add_message_callback(200, self) { |message|
      if !muc.from_room?(message.from) && message.type == :chat && message.body
        time = Time.now # TODO: get real timestamp? Doesn't seem like
                        # jabber gives it to us
        sender_jid = message.from
        plugins = Robut::Plugin.plugins.map { |p| p.new(self, sender_jid) }
        handle_message(plugins, time, self.roster[sender_jid].iname, message.body)
        true
      else
        false
      end
    }
        
    muc.join(config.room + '/' + config.nick)
    loop { sleep 1 }
  end
  
  def plugins
    @plugins ||= Robut::Plugin.plugins.map { |p| p.new(self) }
  end
  
end
