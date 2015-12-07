# This is a proof of concept swift plugin
# Example:
#
#    @robut swift print("Hello world")
#
#
require "open3"
require "securerandom"

class Robut::Plugin::Swift
  include Robut::Plugin

  def handle(time, sender_nick, message)

    message = without_nick(message).lstrip()
    if message.start_with? "swift"

      # Remove swift prefix
      message.sub!("swift", "")

      # Debugging
      # reply(message.inspect())

      # Create a temporary file if it doesn't exist
      file_name = "/tmp/swift-#{SecureRandom.uuid}.swift"
      path_name = Pathname.new(file_name)

      # import Foundation by default
      message = "import Foundation\n#{message}"

      # Write file to disk
      IO.write(file_name, message)

      output, error, status = Open3.capture3("timeout 20 swift #{file_name}")
      if status.success?
        reply(output)
      else
        if status.exitstatus == 124 # Timeout
          reply("Execution took too long, timed out.")
        else
          reply("Something went wrong... #{error}")
        end
      end

      # Remove temporary file
      File.delete(file_name)
    end
  end

  desc "swift <command> - Run swift code"

end
