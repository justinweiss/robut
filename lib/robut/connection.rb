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
  # [+rooms+] The chat room(s) to join, with each in the format <tt>jabber_name</tt>@<tt>conference_server</tt>
  #
  # [+logger+] a logger instance to use for debug output.
  attr_accessor :config

  # The Jabber::Client that's connected to the HipChat server.
  attr_accessor :client

  # The storage instance that's available to plugins
  attr_accessor :store

  # The roster of currently available people
  attr_accessor :roster

  # The rooms that robut is connected to.
  attr_accessor :rooms

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
    self.store = self.config.store || Robut::Storage::HashStore # default to in-memory store only
    self.config.rooms ||= Array(self.config.room) # legacy support?
    self.config.private_message = self.config.private_message || "enable"
    
    if self.config.logger
      Jabber.logger = self.config.logger
      Jabber.debug = true
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

    self.rooms = self.config.rooms.collect do |room_name|
      Robut::Room.new(self, room_name).tap {|r| r.join }
    end

    personal_message = Robut::PM.new(self, rooms) unless self.config.private_message == "disable"

    trap_signals
    self
  end

  # Send a message to all rooms.
  def reply(*args, &block)
    self.rooms.each do |room|
      room.reply(*args, &block)
    end
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
end
