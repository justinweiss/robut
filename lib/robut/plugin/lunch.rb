# Where should we go to lunch today?
class Robut::Plugin::Lunch < Robut::Plugin::Base

  class << self
    attr_accessor :places
  end
  self.places = []
  
  def handles?(time, nick, message)
    words = words(message)
    !self.class.places.empty? && sent_to_me?(message) && words.first && words.first.downcase == "lunch?"
  end

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
