# Where should we go to lunch today?
class Robut::Plugin::Lunch < Robut::Plugin::Base

  class << self
    # A list of possible favorite lunch places. Robut will randomly
    # select one and reply with it. +places+ is an array of strings.
    attr_accessor :places
  end
  self.places = []

  # This plugin is activated when someone sends the message,
  # <tt>@robut lunch?</tt>
  def handles?(time, nick, message)
    words = words(message)
    !self.class.places.empty? && sent_to_me?(message) && words.first && words.first.downcase == "lunch?"
  end

  # Replies with a random string selected from +places+.
  def handle(time, nick, message)
    case words(message).join(' ')
    when "lunch?"
      reply(places[rand(places.length)] + "!")
    when "lunch places"
      reply(places.join(', '))
    end
  end
  
  def places
    self.class.places
  end
end
