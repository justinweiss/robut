# This is a simple plugin the envokes the "say" command on whatever is passed
# Example:
#
#    @robut say that was awesome!
#
# *Requires that the "say" command is installed and in the path
#
class Robut::Plugin::Say
  include Robut::Plugin

  desc "say <words> - uses Mac OS X's 'say' command to speak <words>"
  match "^say (.*)$", :sent_to_me => true do |phrase|
    phrase = clean(phrase)
    system("say #{phrase}")
  end

  private

  def clean(str)
    str.gsub("'", "").gsub(/[^A-Za-z0-9\s]+/, " ").gsub(/\s+/, ' ').strip
  end

end
