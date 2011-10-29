require 'robut/storage/hash_store'

class Robut::PresenceMock < Robut::Room

  def initialize(connection)
    self.connection = connection
  end

  def replies
    @replies ||= []
  end
  
  def reply(msg, to = nil)
    replies << msg
  end
  
  def handle_message(plugins, time, nick, message)
    messages << [time, nick, message]
  end
  
  def messages
    @messages ||= []
  end
  
end
