require 'yaml'

class Robut::Storage::YamlStore < Robut::Storage::Base
    
  class << self

    attr_reader :file

    def file=(f)
      @file = f
      @internal = nil # force reload
      @file
    end

    def []=(k, v)
      internal[k] = v
      persist!
      v
    end
    
    def [](k)
      internal[k]
    end
    
    def internal
      @internal ||= begin
        YAML.load_file(file) rescue {}
      end
    end
    
    def persist!
      raise "Robut::Storage::YamlStore.file must be set" unless file
      f = File.open(file, "w")
      f.puts internal.to_yaml
      f.close
    end
    
  end
    
end