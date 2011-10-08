require 'rdio'
require 'robut/plugin/rdio/server'

# A plugin that hooks into Rdio, allowing you to queue songs from
# HipChat. +key+ and +secret+ must be set before we can deal with any
# Rdio commands. Additionally, you must call +start_server+ in your
# Chatfile to start the Rdio web server.
class Robut::Plugin::Rdio
  include Robut::Plugin

  class << self
    # Your Rdio API Key
    attr_accessor :key

    # Your Rdio API app secret
    attr_accessor :secret

    # The port the Rdio web player will run on. Defaults to 4567.
    attr_accessor :port

    # The host the Rdio web player will run on. Defaults to localhost.
    attr_accessor :host

    # The playback token for +domain+. If you're accessing Rdio on
    # localhost, you shouldn't need to change this. Otherwise,
    # download the rdio-python plugin:
    #
    #   https://github.com/rdio/rdio-python
    #
    # and generate a new token for your domain:
    #
    #   ./rdio-call --consumer-key=YOUR_CONSUMER_KEY --consumer-secret=YOUR_CONSUMER_SECRET getPlaybackToken domain=YOUR_DOMAIN
    attr_accessor :token

    # The domain associated with +token+. Defaults to localhost.
    attr_accessor :domain
  end

  # Starts a Robut::Plugin::Rdio::Server server for communicating with
  # the actual Rdio web player. You must call this in the Chatfile if
  # you plan on using this gem.
  def self.start_server
    @server = Thread.new { Server.run! :host => (host || "localhost"), :port => (port || 4567) }
    Server.token = self.token || "GAlNi78J_____zlyYWs5ZG02N2pkaHlhcWsyOWJtYjkyN2xvY2FsaG9zdEbwl7EHvbylWSWFWYMZwfc="
    Server.domain = self.domain || "localhost"
  end

  # Returns a description of how to use this plugin
  def usage
    [
      "#{at_nick} play <song> - queues <song> for playing",
      "#{at_nick} play album <album> - queues <album> for playing",
      "#{at_nick} play track <track> - queues <track> for playing",
      "#{at_nick} play/unpause - unpauses the track that is currently playing",
      "#{at_nick} next - move to the next track",
      "#{at_nick} restart - restart the current track"
    ]
  end

  # Queues songs into the Rdio web player. @nick play search query
  # will queue the first search result matching 'search query' into
  # the web player. It can be an artist, album, or song.
  def handle(time, sender_nick, message)
    words = words(message)
    
    if sent_to_me?(message)
      
      if words.first == 'play' and words.length > 1
        results = search(words)
        result = results.first
        if result
          Server.queue << result.key
          name = result.name
          name = "#{result.artist_name} - #{name}" if result.respond_to?(:artist_name) && result.artist_name
          reply("Playing #{name}")
        else
          reply("I couldn't find #{words.join(" ")} on Rdio.")
        end
        
      else words.first =~ /play|(?:un)?pause|next|restart|back/
        Server.command << words.first
      end
      
    end
  rescue => exception
    
    reply "Sorry, I made a mistake #{exception}!"
    
  end

  private

  # Searches Rdio for sources matching +words+. If the first word is
  # 'track', it only searches tracks, same for 'album'. Otherwise,
  # matches both albums and tracks.
  def search(words)
    api = ::Rdio::Api.new(self.class.key, self.class.secret)

    if words[1] == "album"
      query_string = words[2..-1].join(' ')
      results = api.search(query_string, "Album")
    elsif words[1] == "track"
      query_string = words[2..-1].join(' ')
      results = api.search(query_string, "Track")
    else
      query_string = words[1..-1].join(' ')
      results = api.search(query_string, "Album,Track")
    end
  end

end
