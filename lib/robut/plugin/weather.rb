require 'open-uri'
require 'nokogiri'

# What's the current weather forecast?
class Robut::Plugin::Weather < Robut::Plugin::Base

  class << self
    attr_accessor :default_location
  end

  def handle(time, sender_nick, message)
    # ignore messages that don't end in ?
    return unless message[message.length - 1] == "?"
    message = message[0..message.length - 2]

    words = words(message)
    i = words.index("weather")

    # ignore messages that don't have "weather" in them
    return if i == -1

    location = i.zero? ? self.class.default_location : words[0..i-1].join(" ")
    if location.nil?
      reply "I don't have a default location!"
      return
    end

    # TODO: parse out day
    if i == words.length - 1
      reply current_conditions(location)
    else
      day = words[i+1..-1].join(" ").downcase
      day = parse_day(day)
      if day.nil?
        reply "I don't understand \"day\""
        return
      end

      reply forecast(location, day)
      return
    end
  end

  def parse_day(day)
    day_map = {
      "monday"    =>  "Mon",
      "mon"       =>  "Mon",
      "tuesday"   =>  "Tue",
      "tue"       =>  "Tue",
      "tues"      =>  "Tue",
      "wed"       =>  "Wed",
      "wednesday" =>  "Wed",
      "thurs"     =>  "Thu",
      "thu"       =>  "Thu",
      "thursday"  =>  "Thu",
      "friday"    =>  "Fri",
      "fri"       =>  "Fri",
      "saturday"  =>  "Sat",
      "sat"       =>  "Sat",
      "sunday"    =>  "Sun",
      "sun"       =>  "Sun",
    }
    if day_map.has_key?(day)
      return day_map[day]
    end

    if day == "tomorrow"
      return (Time.now + 60*60*24).strftime("%a")
    end

    if day == "today"
      return Time.now.strftime("%a")
    end
  end

  def current_conditions(location)
    doc = weather_data(location)
    condition = doc.search("current_conditions condition").first["data"]
    temperature = doc.search("current_conditions temp_f").first["data"]
    "Weather for #{location}: #{condition}, #{temperature}F"
  end

  def forecast(location, day_of_week)
    doc = weather_data(location)
    forecast = doc.search("forecast_conditions").detect{|el| c = el.children.detect{|c| c.name == "day_of_week"}; c && c["data"] == day_of_week}
    return "Can't find a forecast for #{day_of_week}" if forecast.nil?

    condition = forecast.children.detect{|c| c.name == "condition"}["data"]
    high = forecast.children.detect{|c| c.name == "high"}["data"]
    low = forecast.children.detect{|c| c.name == "low"}["data"]
    "Forecast for #{location} on #{day_of_week}: #{condition}, High: #{high}F, Low: #{low}F"
  end

  def weather_data(location = "")
    url = "http://www.google.com/ig/api?weather=#{location}"
    doc = Nokogiri::XML(open(url))
  end

end