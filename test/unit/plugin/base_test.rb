require 'test_helper'

class Robut::Plugin::BaseTest < Test::Unit::TestCase

  def setup
    @plugin = Robut::Plugin::Base.new(Robut::ConnectionMock.new)
  end 

  def test_sent_to_me?
    assert @plugin.sent_to_me?("@Robut hello there")
    assert !@plugin.sent_to_me?("@Robuto hello there")
    assert !@plugin.sent_to_me?("@David hello there")
    assert @plugin.sent_to_me?("this is a @Robut message")
    assert @plugin.sent_to_me?("this is a message to @robut")
    assert !@plugin.sent_to_me?("this is a message to@robut")
  end
  
  def test_without_nick_robut_do_this
    assert_equal "do this", @plugin.without_nick("@robut do this")    
  end
  
  def test_without_nick_do_this_robut
    assert_equal "do this @robut", @plugin.without_nick("do this @robut")
  end

end
