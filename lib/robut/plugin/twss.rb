require 'twss'

# A simple plugin that feeds everything said in the room through the
# twss gem. Requires the 'twss' gem, obviously.
class Robut::Plugin::TWSS
  include Robut::Plugin

  # Returns a description of how to use this plugin
  def usage
    "<words> - responds with \"That's what she said!\" if #{nick} thinks <words> is a valid TWSS"
  end

  # Responds "That's what she said!" if the TWSS gem returns true for
  # +message+. Strips out any reference to our nick in +message+
  # before it stuffs +message+ into the gem.
  def handle(time, sender_nick, message)
    reply("That's what she said!") if ::TWSS.classify(words(message).join(" "))
  end
end
