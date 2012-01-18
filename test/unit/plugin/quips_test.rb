require 'test_helper'
require 'robut/plugin/quips'

class Robut::Plugin::QuipsTest < Test::Unit::TestCase

  def setup
    @connection = Robut::ConnectionMock.new
    @presence = Robut::PresenceMock.new(@connection)
    @plugin = Robut::Plugin::Quips.new(@presence)
    @plugin.store["quips"] = ["the fancier i try and make it, the more complicated it gets!", "It works on my machine ..."]
  end

  def test_add_quip_adds_a_quip_to_the_database
    @plugin.handle(Time.now, "John", "@robut add quip So, are we self managing now?")
    assert_equal ["I added the quip to the quip database"], @plugin.reply_to.replies
    assert_equal "So, are we self managing now?", @plugin.quips.last
  end

  def test_add_quip_without_a_quip_is_ignored
    @plugin.handle(Time.now, "John", "@robut add quip ")
    assert_equal [], @plugin.reply_to.replies
    assert_equal 2, @plugin.quips.length
  end

  def test_add_quip_doesnt_add_duplicates
    @plugin.handle(Time.now, "John", "@robut add quip the fancier i try and make it, the more complicated it gets!")
    assert_equal ["I didn't add the quip, since it was already added"], @plugin.reply_to.replies
    assert_equal 2, @plugin.quips.length
  end

  def test_remove_quip
    @plugin.handle(Time.now, "John", "@robut remove quip the fancier i try and make it, the more complicated it gets!")
    assert_equal ["I removed the quip from the quip database"], @plugin.reply_to.replies
    assert_equal 1, @plugin.quips.length
  end

  def test_remove_nonexisting_quip_returns_error_message
    @plugin.handle(Time.now, "John", "@robut remove quip boooooooo")
    assert_equal ["I couldn't remove the quip, since it wasn't in the quip database"], @plugin.reply_to.replies
    assert_equal 2, @plugin.quips.length
  end

  def test_quip_me_returns_a_random_quip
    seed = srand(1)
    begin
      @plugin.handle(Time.now, "John", "@robut quip")
      assert_equal ["It works on my machine ..."], @plugin.reply_to.replies
    ensure
      srand(seed)
    end
  end

  def test_quip_me_returns_an_error_if_no_quips
    @plugin.store["quips"] = []
    @plugin.handle(Time.now, "John", "@robut quip")
    assert_equal ["I don't know any quips"], @plugin.reply_to.replies
  end
end
