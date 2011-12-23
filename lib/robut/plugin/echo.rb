# A plugin that tells robut to repeat whatever he's told.
class Robut::Plugin::Echo
  include Robut::Plugin

  desc "echo <message> - replies to the channel with <message>"
  match /^echo (.*)/, :sent_to_me => true do |phrase|
    reply(phrase) unless phrase.empty?
  end
end
