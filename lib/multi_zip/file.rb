module MultiZip
  class File
    attr_reader :filename

    BACKEND_PREFERENCE = [ :rubyzip, :zipruby ]
    BACKENDS = {
      :rubyzip => {
        :fingerprints => [
          ['constant', lambda { defined?(Zip::File) } ],
          [nil, lambda { defined?(Zip::Archive) }]
        ],
        :constant => lambda { MultiZip::Backend::Rubyzip }
      },
      :zipruby => {
        :fingerprints => [
          ['constant', lambda { defined?(Zip::File) } ],
          ['constant', lambda { defined?(Zip::Archive) }]
        ],
        :constant => lambda { MultiZip::Backend::Zipruby }
      }
    }

    def initialize(filename, options = {})
      @filename = filename

      self.backend = if b_end = options.delete(:backend)
        b_end
      else
        default_backend
      end

      if block_given?
        yield(self)
      end
    end

    def self.open(filename, opts = {})
      if block_given?
        yield(new(filename, opts))
      else
        new(filename, opts)
      end
    end

    def backend
      @backend ||= default_backend
    end

    def backend=(backend_name)
      return if backend_name.nil?
      if BACKENDS.keys.include?(backend_name.to_sym)
        @backend = backend_name.to_sym
        require "multi_zip/backend/#{@backend}"
        extend BACKENDS[@backend][:constant].call
        return @backend
      else
        raise NoSupportedBackendError, "Not a supported backend. Supported backends are #{BACKENDS.map(&:first).map(&:to_s).sort.join(', ')}"
      end
    end

    # Intended to return the contents of a zip member as a string.
    #
    # This method MUST be overridden by a backend module.
    def read_member(member_path, options={})
      raise NotImplementedError
    end

    # Intended to return the contents of zip members as array of strings.
    #
    # This method MAY be overridden by backend module for the sake of
    # efficiency, or will call #read_member for each entry in member_paths.
    def read_members(member_paths, options={})
      member_paths.map{|f| read_member(f, options) }
    end

    # Intended to write the contents of a zip member to a filesystem path.
    #
    # This method MUST be overridden by a backend module.
    def extract_member(member_path, destination_path, options={})
      raise NotImplementedError
    end

    # List members of the zip file. Optionally can specify a prefix.
    def list_members(prefix = nil, options={})
      raise NotImplementedError
    end

    # Boolean, does a given member path exist in the zip file?
    # This method MAY be overridden by backend module for the sake of
    # efficiency, or will use results of #list_members.
    def member_exists?(member_path, options={})
      list_members(nil, options).include?(member_path)
    end

    # Write string contents to a zip member file
    def write_member(member_path, member_content)
      raise NotImplementedError
    end

  private

    def default_backend
      BACKEND_PREFERENCE.each do |name|
        be = BACKENDS[name]
        if be[:fingerprints].all?{|expectation, lmb| lmb.call == expectation }
          return name
        end
      end
      raise NoSupportedBackendError, "No supported backend found: #{BACKEND_PREFERENCE.join(', ')}"
    end
  end
end