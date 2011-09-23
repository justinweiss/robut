# This is a simple plugin the envokes the "say" command on whatever is passed
# Example:
#
#    @robut say that was awesome!
#
# *Requires that the "say" command is installed and in the path
#
class Robut::Plugin::Say
  include Robut::Plugin

  # Pipes +message+ through the +say+ command
  def handle(time, sender_nick, message)
    words = words(message)
    if sent_to_me?(message) && words.first == "say"
      phrase = clean(words[1..-1].join(' '))
      system("say #{phrase}")
    end
  end

  def clean(str)
    str.gsub("'", "").gsub(/[^A-Za-z0-9\s]+/, " ").gsub(/\s+/, ' ').strip
  end

end
