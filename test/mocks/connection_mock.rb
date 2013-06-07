require 'robut/storage/hash_store'

class Robut::ConnectionMock < Robut::Connection

  attr_accessor :messages

  def initialize(config = nil)
    self.messages = []
    self.config = config || self.class.config
    self.store  = Robut::Storage::HashStore
    self.client = Jabber::Client.new ''
  end

  def connect
    self.rooms = []
    self
  end

  def reply(message, to)
    self.messages << [message, to]
  end
end
