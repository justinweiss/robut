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

    # Create file if it doesn't exist
    file_name = "/tmp/test.swift"
    path_name = Pathname.new(file_name)

    # Write file to disk
    IO.write(file_name, phrase)

    output, error, status = Open3.capture3("swift #{file_name}")
    if status.success?
      reply(output)
    else
      reply("Something wen't wrong... #{error}")
    end
  end

end
