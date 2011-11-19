require 'google-search'

# A simple regex => response plugin.
class Robut::Plugin::GoogleImages
  include Robut::Plugin

  # Returns a description of how to use this plugin
  def usage
    [
      "#{at_nick} image <query> - responds with the first image from a Google Images search for <query>"
    ]
  end


  def handle(time, sender_nick, message)
    return unless sent_to_me?(message)
    words = words(message)
    command = words.shift.downcase
    return unless command == 'image'

    image Google::Search::Image.new(:query => words.join(' ')).first
    
    if image
      reply image.uri
    else
      reply "Couldn't find an image"
    end
  end

end