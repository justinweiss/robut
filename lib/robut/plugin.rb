# Robut plugins implement a simple interface to listen for messages
# and optionally respond to them. All plugins inherit from
# Robut::Plugin::Base.
module Robut::Plugin
  autoload :Base, 'robut/plugin/base'

  class << self
    # A list of all available plugin classes.
    attr_accessor :plugins
  end

  self.plugins = []

end
