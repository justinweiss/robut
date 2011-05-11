require 'calc'

# A simple calculator. This delegates all calculations to the 'calc'
# gem.
class Robut::Plugin::Calc < Robut::Plugin::Base

  # This plugin is enabled when someone sends a message like
  # <tt>@robut calc 1 + 1</tt>
  def handles?(time, nick, message)
    sent_to_me?(message) && command_is?(message, 'calc')
  end

  # Perform the calculation specified in +message+, and send the
  # result back.
  def handle(time, nick, message)
    calculation = words(message, 'calc').join(' ')
    begin
      reply("#{calculation} = #{Calc.evaluate(calculation)}")
    rescue
      reply("Can't calculate that.")
    end
  end

end
