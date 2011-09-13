require 'yaml'

# A store backed by a persistent on-disk yaml file.
class Robut::Storage::YamlStore < Robut::Storage::Base

  class << self

    # The path to the file this store will persist to.
    attr_reader :file

    # Sets the path to the file this store will persist to, and forces
    # a reload of all of the data.
    def file=(f)
      @file = f
      @internal = nil # force reload
      @file
    end

    # Sets the key +k+ to the value +v+
    def []=(k, v)
      internal[k] = v
      persist!
      v
    end

    # Returns the value at the key +k+.
    def [](k)
      internal[k]
    end

    private

    # The internal in-memory representation of the yaml file
    def internal
      @internal ||= load_from_file
    end

    # Persists the data in this store to disk. Throws an exception if
    # we don't have a file set.
    def persist!
      raise "Robut::Storage::YamlStore.file must be set" unless file
      f = File.open(file, "w")
      f.puts internal.to_yaml
      f.close
    end

    def load_from_file
      begin
        store = YAML.load_file(file)
      rescue Errno::ENOENT
      end

      store || Hash.new
    end

  end
end
