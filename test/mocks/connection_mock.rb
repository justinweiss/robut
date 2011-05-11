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
  
  def reply(msg)
    replies << msg
  end
end
