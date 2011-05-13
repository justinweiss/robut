
# A plugin that tells robut to repeat whatever he's told.

class Robut::Plugin::Echo < Robut::Plugin::Base
  
  def handle(time, sender_nick, message)
    words = words(message)
    if sent_to_me?(message) && words.first == 'echo'
      phrase = words[1..-1].join(' ')
      reply(phrase) unless phrase.empty?
    end
  end
  
end