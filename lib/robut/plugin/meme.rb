require 'cgi'

# A simple plugin that wraps meme_generator. Requires the
# 'meme_generator' gem.
class Robut::Plugin::Meme
  include Robut::Plugin

  MEMES = {
    'bear_grylls' => 'http://memecaptain.com/bear_grylls.jpg',
    'insanity_wolf' => 'http://memecaptain.com/insanity_wolf.jpg',
    'most_interesting' => 'http://memecaptain.com/most_interesting.jpg',
    'philosoraptor' => 'http://memecaptain.com/philosoraptor.jpg',
    'scumbag_steve' => 'http://memecaptain.com/scumbag_steve.jpg',
    'town_crier' => 'http://memecaptain.com/town_crier.jpg',
    'troll_face' => 'http://memecaptain.com/troll_face.jpg',
    'y_u_no' => 'http://memecaptain.com/y_u_no.jpg',
    'yao_ming' => 'http://memecaptain.com/yao_ming.jpg',
    'business_cat' => 'http://memecaptain.com/business_cat.jpg',
    'all_the_things' => 'http://memecaptain.com/all_the_things.jpg',
    'fry' => 'http://memecaptain.com/fry.png',
    'sap' => 'http://memecaptain.com/sap.jpg'
  }

  # Returns a description of how to use this plugin
  def usage
    [
      "#{at_nick} meme list - lists all the memes that #{nick} knows about",
      "#{at_nick} meme <meme> <line1>;<line2> - responds with a link to a generated <meme> image using <line1> and <line2>"
    ]
  end

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
    meme = words.first

    if meme == 'list'
      reply("Memes available: #{MEMES.keys.join(', ')}")
    elsif MEMES[meme]
      words.shift
      url = CGI.escape(MEMES[meme])
      line1, line2 = words.join(' ').split(';').map { |line| CGI.escape(line)}
      meme_url = "http://memecaptain.com/i?u=#{url}&tt=#{line1}"
      meme_url += "&tb=#{line2}" if line2
      reply(meme_url)
    else
      reply("Meme not found: #{meme}")
    end
  end

end
