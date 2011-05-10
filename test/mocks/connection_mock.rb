class Robut::ConnectionMock < Robut::Connection

  def initialize(config = nil)
    self.config = config || self.class.config
  end
end
