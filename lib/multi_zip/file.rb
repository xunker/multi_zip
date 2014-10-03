module MultiZip
  class File
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
      if b_end = options.delete(:backend)
        backend = b_end
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
      if BACKENDS.keys.include?(backend_name.to_sym)
        @backend = backend_name.to_sym
        require "multi_zip/backend/#{@backend}"
        extend BACKENDS[@backend][:constant].call
        return @backend
      else
        raise NoSupportedBackendError, "Not a supported backend. Supported backends are #{BACKENDS.map(&:first).map(&:to_s).sort.join(', ')}"
      end
    end

    def read_file(file_path, options={})
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