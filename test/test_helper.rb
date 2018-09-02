require 'robut'
require 'test/unit'
require 'mocks/presence_mock'
require 'mocks/connection_mock'

Robut::ConnectionMock.configure do |config|
  config.nick = "Robut t. Robot"
  config.mention_name = "robut"
  config.on_join_message = "Good morning vietnam!"
end
