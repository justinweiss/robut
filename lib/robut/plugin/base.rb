# All Robut plugins inherit from this base class. Plugins should
# implement the <tt>handles?</tt> and +handle+ methods to implement
# their functionality.
class Robut::Plugin::Base

  # A reference to the connection attached to this instance of the
  # plugin. This is mostly used to communicate back to the server.
  attr_accessor :connection

  # Creates a new instance of this plugin that references the
  # specified connection.
  def initialize(connection)
    self.connection = connection
  end

  # Send +message+ back to the HipChat server.
  def reply(message)
    connection.reply(message)
  end

  # An ordered list of all words in the message with any reference to
  # the bot's nick stripped out. If +command+ is passed in, it is also
  # stripped out. This is useful to separate the 'parameters' from the
  # 'commands' in a message.
  def words(message, command = nil)
    reply = "@#{nick.downcase}"
    command = command.downcase if command
    message.split.reject {|word| word.downcase == reply || word.downcase == command }
  end

  # The bot's nickname, for @-replies.
  def nick
    connection.config.nick.split.first
  end

  # Was +message+ sent to Robut as an @reply?
  def sent_to_me?(message)
    message =~ /(^|\s)@#{nick}(\s|$)/i
  end

  # Is +command+ the first real word in +message+? This is useful for
  # switching based on known commands.
  def command_is?(message, command)
    words = words(message)
    sent_command = words.first
    sent_command && sent_command.downcase == command.downcase
  end

  # Does this plugin handle this kind of message? If so, return
  # +true+, otherwise, return +false+.
  def handles?(time, sender_nick, message)
    false
  end

  # Do whatever you need to do to handle this message.
  def handle(time, sender_nick, message)
    raise NotImplementedError, "Implement me in #{self.class.name}!"
  end
  
end
