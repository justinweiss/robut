class Robut::ConnectionMock < Robut::Connection

  def initialize(config = nil)
    self.config = config || self.class.config
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
