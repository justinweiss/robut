# A simple plugin that replies with "pong" when messaged with ping
class Robut::Plugin::Ping
  include Robut::Plugin

  def usage
    "#{at_nick} ping - responds 'pong'"
  end

  # Responds "pong" if +message+ is "ping"
  def handle(time, sender_nick, message)
    words = words(message)
    reply("pong") if sent_to_me?(message) && words.length == 1 && words.first.downcase == 'ping'
  end

end
