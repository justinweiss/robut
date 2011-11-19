require 'cgi'

# A simple plugin that wraps memecaptain.
class Robut::Plugin::Meme
  include Robut::Plugin

  # Returns a description of how to use this plugin
  def usage
    [
      "#{at_nick} meme <meme> <line1>;<line2> - responds with a link to a generated <meme> image using <line1> and <line2>.  " +
      "See http://memecaptain.com/ for a list of memes.  You can also pass a link to your own image as the meme."
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
  #   @robut meme all_the_things write; all the plugins
  #
  # Send message to the specified meme generator. If the meme requires
  # more than one line of text, lines should be separated with a semicolon.
  def handle(time, sender_nick, message)
    return unless sent_to_me?(message)
    words = words(message)
    command = words.shift.downcase
    return unless command == 'meme'
    meme = words.shift

    if meme.include?("://")
      url = meme
    else
      url = "http://memecaptain.com/#{meme}.jpg"
    end
    line1, line2 = words.join(' ').split(';').map { |line| CGI.escape(line.strip)}
    meme_url = "http://memecaptain.com/i?u=#{url}&tt=#{line1}"
    meme_url += "&tb=#{line2}" if line2
    reply(meme_url)    
  end

end
