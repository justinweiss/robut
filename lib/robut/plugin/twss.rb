require 'twss'

# A simple plugin that feeds everything said in the room through the twss
# gem.
class Robut::Plugin::TWSS < Robut::Plugin::Base

  def handles?(time, sender_nick, message)
    true
  end

  def handle(time, sender_nick, message)
    reply("That's what she said!") if TWSS(words(message).join(" "))
  end
end
