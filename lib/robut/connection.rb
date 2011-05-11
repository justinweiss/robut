require 'xmpp4r'
require 'xmpp4r/muc/helper/simplemucclient'
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

  # Send +message+ to the room we're currently connected to.
  def reply(message)
    muc.send Jabber::Message.new(muc.room, message)
  end

  # Connects to the specified room with the given credentials, and
  # enters an infinite loop. Any messages sent to the room will pass
  # through all the included plugins.
  def connect
    client.connect
    client.auth(config.password)
    client.send(Jabber::Presence.new.set_type(:available))

    plugins = Robut::Plugin.plugins.map { |p| p.new(self) }

    muc.on_message do |time, nick, message|
      plugins.each do |plugin|
        begin
          plugin.handle(time, nick, message)
        rescue => e
          reply("I just pooped myself trying to run #{plugin.class.name}. AWK-WAAAARD!")
        end
      end
    end

    muc.join(config.room + '/' + config.nick)
    loop { sleep 1 }
  end
  
end
