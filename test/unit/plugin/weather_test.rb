require 'test_helper'
require 'webmock/test_unit'
require 'time-warp'
require 'robut/plugin/weather'

class Robut::Plugin::WeatherTest < Test::Unit::TestCase

  def setup
    @connection = Robut::ConnectionMock.new
    @plugin = Robut::Plugin::Weather.new(@connection)
  end

  def teardown
    Robut::Plugin::Weather.default_location = nil
  end

  def test_handle_no_weather
    @plugin.handle(Time.now, "John", "lunch?")
    assert_equal( [], @plugin.connection.replies )

    @plugin.handle(Time.now, "John", "?")
    assert_equal( [], @plugin.connection.replies )
  end

  def test_handle_no_location_no_default
    @plugin.handle(Time.now, "John", "weather?")
    assert_equal( ["I don't have a default location!"], @plugin.connection.replies )
  end

  def test_handle_no_location_default_set
    Robut::Plugin::Weather.default_location = "Seattle"
    stub_request(:any, "http://www.google.com/ig/api?weather=Seattle").to_return(:body => File.open(File.expand_path("../../../fixtures/seattle.xml", __FILE__), "r").read)

    @plugin.handle(Time.now, "John", "weather?")
    assert_equal( ["Weather for Seattle, WA: Mostly Cloudy, 58F"], @plugin.connection.replies )
  end

  def test_handle_location
    stub_request(:any, "http://www.google.com/ig/api?weather=tacoma").to_return(:body => File.open(File.expand_path("../../../fixtures/tacoma.xml", __FILE__), "r").read)

    @plugin.handle(Time.now, "John", "tacoma weather?")
    assert_equal( ["Weather for Tacoma, WA: Cloudy, 60F"], @plugin.connection.replies )
  end

  def test_no_question_mark
    @plugin.handle(Time.now, "John", "seattle weather")
    assert_equal( [], @plugin.connection.replies )
  end

  def test_handle_day
    stub_request(:any, "http://www.google.com/ig/api?weather=Seattle").to_return(:body => File.open(File.expand_path("../../../fixtures/seattle.xml", __FILE__), "r").read)

    pretend_now_is(2011,"may",23,17) do
      @plugin.handle(Time.now, "John", "Seattle weather tuesday?")
      assert_equal( ["Forecast for Seattle, WA on Tue: Partly Cloudy, High: 67F, Low: 51F"], @plugin.connection.replies )
    end
  end

  def test_handle_tomorrow
    stub_request(:any, "http://www.google.com/ig/api?weather=Seattle").to_return(:body => File.open(File.expand_path("../../../fixtures/seattle.xml", __FILE__), "r").read)

    pretend_now_is(2011,"may",23,17) do
      @plugin.handle(Time.now, "John", "Seattle weather tomorrow?")
      assert_equal( ["Forecast for Seattle, WA on Tue: Partly Cloudy, High: 67F, Low: 51F"], @plugin.connection.replies )
    end
  end

  def test_handle_today
    stub_request(:any, "http://www.google.com/ig/api?weather=Seattle").to_return(:body => File.open(File.expand_path("../../../fixtures/seattle.xml", __FILE__), "r").read)

    pretend_now_is(2011,"may",23,17) do
      @plugin.handle(Time.now, "John", "Seattle weather today?")
      assert_equal( ["Forecast for Seattle, WA on Mon: Partly Cloudy, High: 59F, Low: 48F"], @plugin.connection.replies )
    end
  end

  def test_handle_multi_word_location
    stub_request(:any, "http://www.google.com/ig/api?weather=Las%20Vegas").to_return(:body => File.open(File.expand_path("../../../fixtures/las_vegas.xml", __FILE__), "r").read)
    @plugin.handle(Time.now, "John", "Las Vegas weather?")
    assert_equal( ["Weather for Las Vegas, NV: Mostly Cloudy, 83F"], @plugin.connection.replies )
  end

  def test_handle_location_with_comma
    stub_request(:any, "http://www.google.com/ig/api?weather=Las%20Vegas,%20NV").to_return(:body => File.open(File.expand_path("../../../fixtures/las_vegas.xml", __FILE__), "r").read)
    @plugin.handle(Time.now, "John", "Las Vegas, NV weather?")
    assert_equal( ["Weather for Las Vegas, NV: Mostly Cloudy, 83F"], @plugin.connection.replies )
  end

end