require 'xmpp4r'
require 'xmpp4r/muc/helper/simplemucclient'
require 'xmpp4r/roster/helper/roster'
require 'ostruct'

if defined?(Encoding)
  # Monkey-patch an incompatibility between ejabberd and rexml
  require 'rexml_patches'
end

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
  end

  # Sets the instance config to +config+, converting it into an
  # OpenStruct if necessary.
  def config=(config)
    @config = config.kind_of?(Hash) ? OpenStruct.new(config) : config
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
  
  #
  # Return a truthy value if the any filter returned a negative value
  # 
  def filter_message(filters, time, nick, message)
    # ignore all messages sent by robut. If you really want robut to
    # reply to itself, you can use +fake_message+.
    return false if nick == config.nick
    
    filters.detect do |filter|
      
      begin
        filter.handle(time,nick,message) == false
      rescue => e
         reply("UH OH! #{filter.class.name} just crashed!")
         if config.logger
           config.logger.error e
           config.logger.error e.backtrace.join("\n")
         end
         
         false
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

    # Add the callback from messages that occur inside the room
    muc.on_message do |time, nick, message|
      
      filters = Robut::Plugin.filters.map { |f| f.new(self, nil) }
      
      unless filter_message(filters, time, nick, message)
        plugins = Robut::Plugin.plugins.map { |p| p.new(self, nil) }
        handle_message(plugins, time, nick, message)
      end
      
    end

    # Add the callback from direct messages. Turns out the
    # on_private_message callback doesn't do what it sounds like, so I
    # have to go a little deeper into xmpp4r to get this working.
    client.add_message_callback(200, self) do |message|
      if !muc.from_room?(message.from) && message.type == :chat && message.body
        time = Time.now # TODO: get real timestamp? Doesn't seem like
                        # jabber gives it to us
        sender_jid = message.from
        
        filters = Robut::Plugin.filters.map { |f| f.new(self, nil) }
        
        unless filter_message(filters, time, nick, message)
          plugins = Robut::Plugin.plugins.map { |p| p.new(self, sender_jid) }
          handle_message(plugins, time, self.roster[sender_jid].iname, message.body)
        end
        
        true
      else
        false
      end
    end

    muc.join(config.room + '/' + config.nick)

    trap_signals
    loop { sleep 1 }
  end

  private

  # Since we're entering an infinite loop, we have to trap TERM and
  # INT. If something like the Rdio plugin has started a server that
  # has already trapped those signals, we want to run those signal
  # handlers first.
  def trap_signals
    old_signal_callbacks = {}
    signal_callback = Proc.new do |signal|
      old_signal_callbacks[signal].call if old_signal_callbacks[signal]
      exit
    end

    [:INT, :TERM].each do |sig|
      old_signal_callbacks[sig] = trap(sig) { signal_callback.call(sig) }
    end
  end

  # Find a jid in the roster with the given name, case-insensitively
  def find_jid_by_name(name)
    name = name.downcase
    roster.items.detect {|jid, item| item.iname.downcase == name}.first
  end
end
