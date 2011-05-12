
# A simple plugin that replies with "pong" when messaged with ping
class Robut::Plugin::Ping < Robut::Plugin::Base

  # Responds "That's what she said!" if the TWSS gem returns true for
  # +message+. Strips out any reference to our nick in +message+
  # before it stuffs +message+ into the gem.
  def handle(time, sender_nick, message)
    words = words(message)
    reply("pong") if sent_to_me?(message) && words.length == 1 && words.first.downcase == 'ping'
  end
  
end
