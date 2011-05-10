# A simple regex => response plugin.
class Robut::Plugin::Sayings < Robut::Plugin::Base

  class << self
    # A list of arrays. The first element is a regex, the second is
    # the reply sent if the regex matches. After the first match, we
    # don't try to match any other sayings.
    attr_accessor :sayings
  end
  self.sayings = []

  def handles?(time, nick, message)
    sent_to_me?(message)
  end

  def handle(time, nick, message)
    self.class.sayings.each do |saying|
      if words(message).join(' ').match(/#{saying.first}/i)
        reply(saying.last)
        return
      end
    end
  end
end
