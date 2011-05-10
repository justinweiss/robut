require 'test_helper'

class Robut::Plugin::BaseTest < Test::Unit::TestCase

  def test_sent_to_me?
    plugin = Robut::Plugin::Base.new(Robut::ConnectionMock.new)

    assert plugin.sent_to_me?("@Robut hello there")
    assert !plugin.sent_to_me?("@Robuto hello there")
    assert !plugin.sent_to_me?("@David hello there")
    assert plugin.sent_to_me?("this is a @Robut message")
    assert plugin.sent_to_me?("this is a message to @robut")
    assert !plugin.sent_to_me?("this is a message to@robut")
  end

end
