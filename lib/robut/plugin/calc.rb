require 'calc'

# A simple calculator.
class Robut::Plugin::Calc < Robut::Plugin::Base

  def handles?(time, nick, message)
    sent_to_me?(message) && command_is?(message, 'calc')
  end

  def handle(time, nick, message)
    calculation = words(message, 'calc').join(' ')
    begin
      reply("#{calculation} = #{Calc.evaluate(calculation)}")
    rescue
      reply("Can't calcualte that.")
    end
  end

end
