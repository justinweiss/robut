# A simple plugin that replies with "pong" when messaged with ping
class Robut::Plugin::Ping
  include Robut::Plugin

  desc "ping - responds 'pong'"
  match /^ping$/, :sent_to_me => true do
    reply("pong")
  end
end
