require 'sinatra'
require 'json'

class Robut::Plugin::Rdio < Robut::Plugin::Base
  
  # A simple server to communicate new Rdio sources to the Web
  # Playback API. The client will update
  # Robut::Plugin::Rdio::Server.queue with any new sources, and a call
  # to /queue.json will pull those new sources as a json object.
  class Server < Sinatra::Base

    set :root, File.dirname(__FILE__)
    
    class << self
      # A list of items that haven't been fetched by the web playback
      # API yet.
      attr_accessor :queue

      # The playback token for +domain+. If you're accessing Rdio over
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
    self.queue = []

    # Renders a simple Rdio web player.
    get '/' do
      File.read(File.expand_path('public/index.html', File.dirname(__FILE__)))
    end

    get '/js/vars.js' do
      content_type 'text/javascript'
      <<END
var rdio_token = '#{self.class.token}';
var rdio_domain = '#{self.class.domain}';
END
    end

    # Returns the sources that haven't been fetched yet.
    get '/queue.json' do
      queue = self.class.queue.dup
      self.class.queue = []
      queue.to_json
    end
  end
end

