# This is a proof of concept swift plugin
# Example:
#
#    @robut swift print("Hello world")
#
#
require "open3"

class Robut::Plugin::Swift
  include Robut::Plugin

  desc "swift <command> - Run swift code"
  match "^swift (.*)$", :sent_to_me => true do |phrase|
    output, status = Open3.capture2("swift #{phrase}")
    if status.success?
      reply(output)
    else
      reply("Something wen't wrong...")
    end
  end

end
