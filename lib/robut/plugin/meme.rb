require 'meme'

# A simple plugin that wraps meme_generator. Requires the
# 'meme_generator' gem.
class Robut::Plugin::Meme < Robut::Plugin::Base

  # This plugin is activated when robut is sent a message starting
  # with the name of a meme. The list of generators can be discovered
  # by running
  # 
  #   meme list
  #
  # from the command line. Example:
  #
  #   @robut h_mermaid look at this stuff, isn't it neat; my vinyl collection is almost complete
  #
  # Send message to the specified meme generator. If the meme requires
  # more than one line of text, lines should be separated with a semicolon.
  def handle(time, nick, message)
    word = words(message).first
    if sent_to_me?(message && Meme::GENERATORS.has_key?(word.upcase))
      words = words(message)
      g = Meme.new(words.shift.upcase)
      line1, line2 = words.join(' ').split(';')
    
      reply(g.generate(line1, line2))
    end
  end
  
end
