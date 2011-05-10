require 'meme'

# A simple plugin that wraps meme_generator.
class Robut::Plugin::Meme < Robut::Plugin::Base

  def handles?(time, nick, message)
    word = words(message).first
    sent_to_me?(message) && Meme::GENERATORS.has_key?(word.upcase)
  end

  def handle(time, nick, message)
    words = words(message)
    g = Meme.new(words.shift.upcase)
    line1, line2 = words.join(' ').split(';')
    
    reply(g.generate(line1, line2))
  end
  
end
