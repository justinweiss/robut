require 'robut/storage/hash_store'

class Robut::ConnectionMock < Robut::Connection

  def initialize(config = nil)
    self.config = config || self.class.config
    self.store = Robut::Storage::HashStore
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
