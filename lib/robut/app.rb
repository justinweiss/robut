require 'sinatra/base'

module Robut
  class App < Sinatra::Base
    helpers do
      def say(*args)
        reply(*args)
      end

      def connection
        settings.connection
      end

      def reply(*args)
        connection.reply(*args)
      end
    end

    get '/' do
      'ok'
    end
  end
end
