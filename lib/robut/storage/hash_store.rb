require 'yaml'

class Robut::Storage::HashStore < Robut::Storage::Base
    
  class << self

    def []=(k, v)
      internal[k] = v
    end
    
    def [](k)
      internal[k]
    end
    
    def internal
      @internal ||= {}
    end
    
  end
    
end