require 'shellwords'

# Alias robut commands:
#
# @robut alias "something" "some long message"
#
# Later if @robut receives the message "@robut something" he will
# repond as if he received "@robut some long message"
#
#
# Valid use:
#
#   @robut alias this "something long"
#   @robut alias "this thing" "something long"
#   @robut alias this something_long
#
# Listing all aliases
#
#   @robut aliases
#
# Removing aliases
#
#   @robut remove alias "this alias"
#   @robut remove alias this
#   @robut remove clear aliases # removes everything
#
# Note: you probably want the Alias plugin as one of the first things
# in the plugin array (since plugins are executed in order).
class Robut::Plugin::Alias < Robut::Plugin::Base

  # Perform the calculation specified in +message+, and send the
  # result back.
  def handle(time, sender_nick, message)
    if new_message = get_alias(message)
      # Apply the alias
      fake_message Time.now, sender_nick, new_message
    elsif sent_to_me?(message)
      message = without_nick message
      if message =~ /^remove alias (.*)/
        # Remove the alias
        key = parse_alias_key($1)
        remove_alias key
        return true
      elsif message =~ /^clear aliases$/
        self.aliases = {}
        return true
      elsif message =~ /^alias (.*)/
        # Create a new alias
        message = $1
        key, value = parse_alias message
        store_alias key, value
        return true # hault plugin execution chain
      elsif words(message).first == 'aliases'
        # List all aliases
        m = []
        aliases.each { |key, value| m << "#{key} => #{value}" }
        reply m.join("\n")
        return true
      end
    end
  end
  
  # Given a message, returns what it is aliased to (or nil)
  def get_alias(msg)
    (store['aliases'] || {})[msg]
  end
  
  def store_alias(key, value)
    aliases[key] = value
    store['aliases'] = aliases
  end
  
  def remove_alias(key)
    new_aliases = aliases
    new_aliases.delete(key)
    store['aliases'] = new_aliases
  end
  
  def aliases
    store['aliases'] ||= {}
  end
  
  def aliases=(v)
    store['aliases'] = v
  end
  
  # Returns alias and command
  def parse_alias(str)
    r = Shellwords.shellwords str
    return r[0], r[1] if r.length == 2
    return r[0], r[1..-1].join(' ')
  end
  
  def parse_alias_key(str)
    Shellwords.shellwords(str).join(' ')
  end
    
end
