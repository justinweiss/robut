
module ReplyMock
  
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