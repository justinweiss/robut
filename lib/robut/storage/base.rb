# A Robut::Storage implementation is a simple key-value store
# accessible to all plugins. Plugins can access the global storage
# object with the method +store+. All storage implementations inherit
# from Robut::Storage::Base. All implementations must implement the class
# methods [] and []=.
class Robut::Storage::Base
  
  class << self

    # Sets the key +k+ to the value +v+ in the current storage system
    def []=(k,v)
      raise "Must be implemented"
    end

    # Returns the value at the key +k+.
    def [](k)
      raise "Must be implemented"
    end
  end

end
