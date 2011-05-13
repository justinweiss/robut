
# This is a simple plugin the envokes the "say" command on whatever is passed
# Example:
#
#    @robut say that was awesome!
#
# *Requires that the "say" command is installed and in the path
#
class Robut::Plugin::Say < Robut::Plugin::Base
  
  def handle(time, sender_nick, message)
    words = words(message)
    if sent_to_me?(message) && words.first == "say"
      phrase = words[1..-1].join(' ')
      system("say #{phrase}")
    end
  end
  
end