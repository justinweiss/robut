# All Robut plugins inherit from this base class. Plugins should
# implement the +handle+ method to implement their functionality.
class Robut::Plugin::Base

  # A reference to the connection attached to this instance of the
  # plugin. This is mostly used to communicate back to the server.
  attr_accessor :connection

  # If we are handling a private message, holds a reference to the
  # sender of the message. +nil+ if the message was sent to the entire
  # room.
  attr_accessor :private_sender

  # Creates a new instance of this plugin that references the
  # specified connection.
  def initialize(connection, private_sender = nil)
    self.connection = connection
    self.private_sender = private_sender
  end

  # Send +message+ back to the HipChat server. If +to+ == +:room+,
  # replies to the room. If +to+ == nil, responds in the manner the
  # original message was sent. Otherwise, PMs the message to +to+.
  def reply(message, to = nil)
    if to == :room
      connection.reply(message, nil)
    else
      connection.reply(message, to || private_sender)
    end
  end

  # An ordered list of all words in the message with any reference to
  # the bot's nick stripped out. If +command+ is passed in, it is also
  # stripped out. This is useful to separate the 'parameters' from the
  # 'commands' in a message.
  def words(message, command = nil)
    reply = at_nick
    command = command.downcase if command
    message.split.reject {|word| word.downcase == reply || word.downcase == command }
  end

  # The bot's nickname, for @-replies.
  def nick
    connection.config.nick.split.first
  end

  # #nick with the @-symbol prepended
  def at_nick
    "@#{nick.downcase}"
  end

  # Was +message+ sent to Robut as an @reply?
  def sent_to_me?(message)
    message =~ /(^|\s)@#{nick}(\s|$)/i
  end

  # Do whatever you need to do to handle this message.
  # If you want to stop the plugin execution chain, return +true+ from this
  # method.  Plugins are handled in the order that they appear in
  # Robut::Plugin.plugins
  def handle(time, sender_nick, message)
    raise NotImplementedError, "Implement me in #{self.class.name}!"
  end
  
  # Accessor for the store instance
  def store
    connection.store
  end
  
end
