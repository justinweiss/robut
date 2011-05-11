

class Robut::Storage::Base
  
  class << self
    def []=(k,v)
      raise "Must be implemented"
    end
  
    def [](k)
      raise "Must be implemented"
    end
  end

end