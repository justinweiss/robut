# Robut plugins implement a simple interface to listen for messages
# and optionally respond to them. All plugins include the Robut::Plugin
# module.
module Robut::Plugin

  # Contains methods that will be added directly to a class including
  # Robut::Plugin.
  module ClassMethods

    # Sets up a 'matcher' that will try to match input being sent to
    # this plugin with a regular expression. If the expression
    # matches, +action+ will be performed. +action+ will be passed any
    # captured groups in the regular expression as parameters. For
    # example:
    #
    #     match /^say hello to (\w+)/ do |name| ...
    #
    # The action is run in the context of an instance of a class that
    # includes Robut::Plugin. Like +handle+, an action explicitly
    # returning +true+ will stop the plugin chain from matching any
    # further.
    #
    # Supported options:
    #   :sent_to_me - only try to match this regexp if it contains an @reply to robut.
    #                 This will also strip the @reply from the message we're trying
    #                 to match on, so ^ and $ will still do the right thing.
    def match(regexp, options = {}, &action)
      matchers << [regexp, options, action, @last_description]
      @last_description = nil
    end

    # Provides a description for the next matcher
    def desc(string)
      @last_description = string
    end

    # A list of regular expressions to apply to input being sent to
    # the plugin, along with blocks of actions to perform. Each
    # element is a [regexp, options, action, description] array.
    def matchers
      @matchers ||= []
    end
  end

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

  # :nodoc:
  def self.included(klass)
    klass.send(:extend, ClassMethods)
  end

  # Creates a new instance of this plugin to reply to a particular
  # object over that object's connection
  def initialize(reply_to, private_sender = nil)
    self.reply_to = reply_to
    self.connection = reply_to.connection
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
    if matchers.empty?
      raise NotImplementedError, "Implement me in #{self.class.name}!"
    else
      find_match(message)
    end
  end

  # Returns a list of messages describing the commands this plugin
  # handles.
  def usage
    matchers.map do |regexp, options, action, description|
      next unless description
      if options[:sent_to_me]
        at_nick + " " + description
      else
        description
      end
    end.compact
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

  private

  # Find and run all the actions associated with matchers that match
  # +message+.
  def find_match(message)
    matchers.each do |regexp, options, action, description|
      if options[:sent_to_me] && !sent_to_me?(message)
        next
      end

      if match_data = without_nick(message).match(regexp)
        # Return true explicitly if this matcher explicitly returned true
        break true if instance_exec(*match_data[1..-1], &action) == true
      end
    end
  end

  # The matchers defined by this plugin's class
  def matchers
    self.class.matchers
  end
end
