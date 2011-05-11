require 'test_helper'
require 'robut/plugin/lunch'

class Robut::Plugin::LunchTest < Test::Unit::TestCase

  def setup
    @connection = Robut::ConnectionMock.new
    @plugin = Robut::Plugin::Lunch.new(@connection)
    @plugin.places = ["Pho"]
  end

  def test_handle_returns_pho_for_lunch
    @plugin.handle(Time.now, "John", "lunch?")
    assert_equal ["Pho!"], @plugin.connection.replies
  end
  
  def test_handle_returns_all_places_for_lunch_places
    @plugin.new_place("Teriyaki")
    @plugin.handle(Time.now, "John", "@robut lunch places")
    assert_equal ["Pho, Teriyaki"], @plugin.connection.replies
  end
  
  def test_handle_new_lunch_place
    @plugin.handle(Time.now, "John", "@robut new lunch place Green Leaf")
    assert_equal ["Ok, I'll add \"Green Leaf\" to the the list of lunch places"], @plugin.connection.replies
    assert @plugin.places.include?("Green Leaf")
  end
  
  def test_handle_remove_lunch_place
    @plugin.handle(Time.now, "John", "@robut remove lunch place Pho")
    assert_equal ["I removed \"Pho\" from the list of lunch places"], @plugin.connection.replies
    assert @plugin.places.empty?
  end

end
