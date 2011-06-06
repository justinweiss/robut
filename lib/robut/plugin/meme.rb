require 'meme'

# A simple plugin that wraps meme_generator. Requires the
# 'meme_generator' gem.
class Robut::Plugin::Meme < Robut::Plugin::Base

  # This plugin is activated when robut is sent a message starting
  # with the name of a meme. The list of generators can be discovered
  # by running
  # 
  #   @robut meme list
  #
  # from the command line. Example:
  #
  #   @robut meme h_mermaid look at this stuff, isn't it neat; my vinyl collection is almost complete
  #
  # Send message to the specified meme generator. If the meme requires
  # more than one line of text, lines should be separated with a semicolon.
  def handle(time, sender_nick, message)
    return unless sent_to_me?(message)
    words = words(message)
    command = words.shift.downcase
    return unless command == 'meme'
    meme = words.first.upcase

    # The meme_generator gem (1.9) is currently broken, so return an error
    reply('Meme plugin is currently broken: https://github.com/justinweiss/robut/issues/8 :(')
    return

    if meme == 'LIST'
      reply("Memes available: #{Meme::GENERATORS.keys.join(', ')}")
    elsif Meme::GENERATORS.has_key?(meme)
      g = Meme.new(meme)
      line1, line2 = words.join(' ').split(';')
      reply(g.generate(line1, line2))
    else
      reply("Meme not found: #{meme}")
    end
  end

end
