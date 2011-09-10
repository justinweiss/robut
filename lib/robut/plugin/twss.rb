require 'twss'

# A simple plugin that feeds everything said in the room through the
# twss gem. Requires the 'twss' gem, obviously.
class Robut::Plugin::TWSS
  include Robut::Plugin

  # Responds "That's what she said!" if the TWSS gem returns true for
  # +message+. Strips out any reference to our nick in +message+
  # before it stuffs +message+ into the gem.
  def handle(time, sender_nick, message)
    reply("That's what she said!") if TWSS(words(message).join(" "))
  end
end
