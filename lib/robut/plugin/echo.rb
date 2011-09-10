# A plugin that tells robut to repeat whatever he's told.
class Robut::Plugin::Echo
  include Robut::Plugin

  # Responds with +message+ if the command sent to robut is 'echo'.
  def handle(time, sender_nick, message)
    words = words(message)
    if sent_to_me?(message) && words.first == 'echo'
      phrase = words[1..-1].join(' ')
      reply(phrase) unless phrase.empty?
    end
  end

end
