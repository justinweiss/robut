require 'twss'

# A simple plugin that feeds everything said to robut through the twss
# gem.
class Robut::Plugin::TWSS < Robut::Plugin::Base

  def handles?(time, sender_nick, message)
    sent_to_me?(message)
  end

  def handle(time, sender_nick, message)
    reply("That's what she said!") if TWSS(message)
  end
end
