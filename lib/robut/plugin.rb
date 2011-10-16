# Robut plugins implement a simple interface to listen for messages
# and optionally respond to them. All plugins include the Robut::Plugin
# module.
module Robut::Plugin

  class << self
    # A list of all available plugin classes. When you require a new
    # plugin class, you should add it to this list if you want it to
    # respond to messages.
    attr_accessor :plugins
  end

  self.plugins = []

  # A reference to the connection attached to this instance of the
  # plugin. This is mostly used to communicate back to the server.
  attr_accessor :connection

  # If we are handling a private message, holds a reference to the
  # sender of the message. +nil+ if the message was sent to the entire
  # room.
  attr_accessor :private_sender

  attr_accessor :reply_to

  # Creates a new instance of this plugin that references the
  # specified connection.
  def initialize(connection, reply_to, private_sender = nil)
    self.reply_to = reply_to
    self.connection = connection
    self.private_sender = private_sender
  end

  # Send +message+ back to the HipChat server. If +to+ == +:room+,
  # replies to the room. If +to+ == nil, responds in the manner the
  # original message was sent. Otherwise, PMs the message to +to+.
  def reply(message, to = nil)
    if to == :room
      reply_to.reply(message, nil)
    else
      reply_to.reply(message, to || private_sender)
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

  # Removes the first word in message if it is a reference to the bot's nick
  # Given "@robut do this thing", Returns "do this thing"
  def without_nick(message)
    possible_nick, command = message.split(' ', 2)
    if possible_nick == at_nick
      command
    else
      message
    end
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

  # Returns a list of messages describing the commands this plugin
  # handles.
  def usage
  end

  def fake_message(time, sender_nick, msg)
    # TODO: ensure this connection is threadsafe
    plugins = Robut::Plugin.plugins.map { |p| p.new(reply_to, private_sender) }
    reply_to.handle_message(plugins, time, sender_nick, msg)
  end

  # Accessor for the store instance
  def store
    connection.store
  end
end
