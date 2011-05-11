require 'test_helper'
require 'robut/plugin/lunch'

class Robut::Plugin::LunchTest < Test::Unit::TestCase

  def setup
    Robut::Plugin::Lunch.places = []
    Robut::Plugin::Lunch.places << "Pho"
    @connection = Robut::ConnectionMock.new
    @plugin = Robut::Plugin::Lunch.new(@connection)
  end

  def test_handles_lunch_returns_true
    assert @plugin.handles?(Time.now, "John", "@robut lunch?")
  end
  
  def test_handles_garbage_returns_false
    assert !@plugin.handles?(Time.now, nil, "@robut ummmm... lunch?")
  end
  
  def test_handle_returns_pho_for_lunch
    @plugin.handle(Time.now, "John", "lunch?")
    assert_equal ["Pho!"], @plugin.connection.replies
  end
  
  def test_handle_returns_all_places_for_lunch_places
    Robut::Plugin::Lunch.places << "Teriyaki"
    @plugin.handle(Time.now, "John", "lunch places")
    assert_equal ["Pho, Teriyaki"], @plugin.connection.replies
  end

end
