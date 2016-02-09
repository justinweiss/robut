require 'net/http'
require 'json'

# Responds with the first google image search result matching a query.
# The easy way to fetch images no longer works. Now, you have to
# follow the steps here:
# http://stackoverflow.com/questions/34035422/google-image-search-says-api-no-longer-available
# to create a search engine and fetch an API key. When you're done,
# configure this plugin with those values.
class Robut::Plugin::GoogleImages
  include Robut::Plugin

  class << self
    # Your google app's API key. 
    attr_accessor :api_key

    # Your custom search engine ID.
    attr_accessor :cse_id
  end

  desc "image <query> - responds with the first image from a Google Images search for <query>"
  match /^image (.*)/, :sent_to_me => true do |query|
    unless self.class.api_key && self.class.cse_id
      reply "You need to set an API key and CSE id to use the Google Images plugin"
      return
    end
    
    image = get_image(query)
    puts image.inspect
    if image
      reply image
    else
      reply "Couldn't find an image"
    end
  end

  private

  def build_search_url(api_key, cse_id, query)
    URI.parse "https://www.googleapis.com/customsearch/v1?key=#{api_key}&cx=#{cse_id}&q=#{URI.escape(query)}&safe=high"
  end
  
  def request_image_json(query)
    Net::HTTP.get build_search_url(self.class.api_key, self.class.cse_id, query)
  end

  def detect_image(item)
    item.fetch("pagemap", {}).fetch("cse_image", [{}]).first["src"]
  end
  
  def get_image(query)
    results = JSON.parse(request_image_json(query))
    results.fetch("items", []).map {|item| detect_image(item) }.compact.first
  end
end
