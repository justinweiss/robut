require 'sinatra/base'

module Robut
  class Web < Sinatra::Base
    helpers do
      # Say something to all connected rooms. Delegates to #reply
      def say(*args)
        reply(*args)
      end

      # Easy access to the current connection context.
      def connection
        settings.connection
      end

      # Delegates to Connection#reply
      def reply(*args)
        connection.reply(*args)
      end
    end

    get '/' do
      'ok'
    end
  end
end
