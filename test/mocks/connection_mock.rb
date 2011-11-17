require 'robut/storage/hash_store'

class Robut::ConnectionMock < Robut::Connection

  def initialize(config = nil)
    self.config = config || self.class.config
    self.store  = Robut::Storage::HashStore
    self.client = Jabber::Client.new ''
  end
end
