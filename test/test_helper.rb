require 'robut'
require 'test/unit'
require 'mocks/connection_mock'

Robut::ConnectionMock.configure do |config|
  config.nick = "Robut t. Robot"
end