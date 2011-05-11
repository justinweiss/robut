require 'robut'
require 'test/unit'
require 'mocks/connection_mock'
require 'mocks/reply_mock'

Robut::ConnectionMock.configure do |config|
  config.nick = "Robut t. Robot"
end

class Test::Unit::TestCase
  
  def mock_replies(plugin)
    plugin.instance_eval do
      extend ReplyMock
    end
  end
  
end