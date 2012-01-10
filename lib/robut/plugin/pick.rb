require 'calc'

# Let fate decide!
class Robut::Plugin::Pick
  include Robut::Plugin

  desc "pick <a>, <b>, <c>, ...  - randomly selects one of the options"
  match /^pick (.*)/, :sent_to_me => true do |message|
    options = message.split(',').map { |s| s.strip }
    rsp = options[random(options.length)]
    reply("And the winner is... #{rsp}") if rsp
  end

  def random(c)
    rand(c)
  end

end
