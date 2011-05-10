# Where should we go to lunch today?
class Robut::Plugin::Lunch < Robut::Plugin::Base

  class << self
    attr_accessor :places
  end
  self.places = []
  
  def handles?(time, nick, message)
    !self.class.places.empty? && sent_to_me?(message) && words(message).first && words(message).first.downcase == "lunch?"
  end

  def handle(time, nick, message)
    reply(self.class.places[rand(self.class.places.length)] + "!")
  end
end
