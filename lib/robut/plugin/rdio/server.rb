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
    end
    self.queue = []

    # Renders a simple Rdio web player.
    get '/' do
      File.read(File.expand_path('public/index.html', File.dirname(__FILE__)))
    end

    # Returns the sources that haven't been fetched yet.
    get '/queue.json' do
      queue = self.class.queue.dup
      self.class.queue = []
      queue.to_json
    end
  end
end

