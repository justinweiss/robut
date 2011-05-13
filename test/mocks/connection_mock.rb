require 'robut/storage/hash_store'

class Robut::ConnectionMock < Robut::Connection

  def initialize(config = nil)
    self.config = config || self.class.config
    self.store = Robut::Storage::HashStore
  end

  def clear_replies!
    @replies = []
  end
  
  def replies
    @replies ||= []
  end
  
  def reply(msg, to = nil)
    if to
      replies << [to, msg]
    else
      replies << msg
    end
  end
  
  def handle_message(time, nick, message)
    messages << [time, nick, message]
  end
  
  def messages
    @messages ||= []
  end
  
end
