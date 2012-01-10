require 'calc'

# Let fate decide!
class Robut::Plugin::Pick
  include Robut::Plugin

  # Returns a description of how to use this plugin
  def usage
    "#{at_nick} pick <a>, <b>, <c>, ...  - randomly selects one of the options"
  end
  
  # Perform the calculation specified in +message+, and send the
  # result back.
  def handle(time, sender_nick, message)
    if sent_to_me?(message) && words(message).first == 'pick'
      options = words(message, 'pick').join(' ').split(',').map { |s| s.strip }
      rsp = options[random(options.length)]
      reply("And the winner is... #{rsp}") if rsp
    end
  end
  
  def random(c)
    rand(c)
  end

end
