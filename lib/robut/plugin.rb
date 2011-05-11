# Robut plugins implement a simple interface to listen for messages
# and optionally respond to them. All plugins inherit from
# Robut::Plugin::Base.
module Robut::Plugin
  autoload :Base, 'robut/plugin/base'

  class << self
    # A list of all available plugin classes. When you require a new
    # plugin class, you should add it to this list if you want it to
    # respond to messages.
    attr_accessor :plugins
  end

  self.plugins = []

end
