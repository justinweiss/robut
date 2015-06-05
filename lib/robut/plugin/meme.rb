require 'cgi'

# A simple plugin that wraps memecaptain.
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
class Robut::Plugin::Meme
  include Robut::Plugin

  desc "meme <meme> <line1>;<line2> - responds with a link to a generated <meme> image using <line1> and <line2>.  " +
    "See http://memecaptain.com/ for a list of memes.  You can also pass a link to your own image as the meme."
  match /^meme (\S+) (.*)$/, :sent_to_me => true do |meme, text|
    # prepend http:// if meme looks like a URL without a scheme
    # - allows submission of image URLs without hipchat adding an image preview
    meme = "http://#{meme}" if meme =~ /[a-z0-9]+\.[a-z0-9]+\//i && !meme.include?("://")

    if meme.include?("://")
      url = meme
    else
      url = "http://memecaptain.com/#{meme}.jpg"
    end
    line1, line2 = text.split(';').map { |line| CGI.escape(line.strip)}
    meme_url = "http://memecaptain.com/i?u=#{url}&tt=#{line1}"
    meme_url += "&tb=#{line2}" if line2
    reply(meme_url)
  end
end
