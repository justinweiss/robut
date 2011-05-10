# All Robut plugins inherit from this base class. Plugins should
# implement the <tt>handles?</tt> and +handle+ methods to implement
# their functionality.
class Robut::Plugin::Base

  # A reference to the connection attached to this instance of the
  # plugin. This is mostly used to communicate back to the server.
  attr_accessor :connection

  # Creates a new instance of this plugin, referencing the specified
  # connection.
  def initialize(connection)
    self.connection = connection
  end

  # Send +message+ back to the server.
  def reply(message)
    connection.reply(message)
  end

  # Was message sent to Robut?
  def sent_to_me?(message)
    message =~ /(^|\s)@#{connection.config.nick.split.first}(\s|$)/i
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
