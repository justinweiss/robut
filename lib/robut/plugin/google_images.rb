require 'google-search'

# Responds with the first google image search result matching a query.
class Robut::Plugin::GoogleImages
  include Robut::Plugin

  desc "image <query> - responds with the first image from a Google Images search for <query>"
  match /^image (.*)/, :sent_to_me => true do |query|
    image = Google::Search::Image.new(:query => query, :safe => :active).first

    if image
      reply image.uri
    else
      reply "Couldn't find an image"
    end
  end
end
