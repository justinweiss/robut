require 'rdio'
require 'robut/plugin/rdio/server'

# A plugin that hooks into Rdio, allowing you to queue songs from
# HipChat. +key+ and +secret+ must be set before we can deal with any
# Rdio commands. Additionally, you must call +start_server+ in your
# Chatfile to start the Rdio web server.
class Robut::Plugin::Rdio < Robut::Plugin::Base

  class << self
    # Your Rdio API Key
    attr_accessor :key
    
    # Your Rdio API app secret
    attr_accessor :secret

    # The port the Rdio web player will run on. Defaults to 4567.
    attr_accessor :port

    # The host the Rdio web player will run on. Defaults to localhost.
    attr_accessor :host
  end

  # Starts a Robut::Plugin::Rdio::Server server for communicating with
  # the actual Rdio web player. You must call this in the Chatfile if
  # you plan on using this gem.
  def self.start_server
    @server = Thread.new { Server.run! :host => (host || "localhost"), :port => (port || 4567) }
  end

  # Queues songs into the Rdio web player. @nick play search query
  # will queue the first search result matching 'search query' into
  # the web player. It can be an artist, album, or song.
  def handle(time, sender_nick, message)
    words = words(message)
    if sent_to_me?(message) && words.first == 'play'
      results = search(words)
      result = results.first
      if result
        Server.queue << result.key
        name = result.name
        name = "#{result.artist_name} - #{name}" if result.respond_to?(:artist_name) && result.artist_name
        reply("Playing #{name}")
      else
        reply("I couldn't find #{query_string} on Rdio.")
      end
    end
  end

  private

  # Searches Rdio for sources matching +words+. If the first word is
  # 'track', it only searches tracks, same for 'album'. Otherwise,
  # matches both albums and tracks.
  def search(words)
    api = Rdio::Api.new(self.class.key, self.class.secret)
    
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
