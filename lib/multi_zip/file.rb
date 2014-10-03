module MultiZip
  class File
    # backends supported in order of preference
    BACKENDS = [
      [
        :rubyzip,  {
          :fingerprints => [
            ['constant', lambda { defined?(Zip::File) } ],
            [nil, lambda { defined?(Zip::Archive) }]
          ]
        }
      ],
      [
        :zipruby, {
          :fingerprints => [
            ['constant', lambda { defined?(Zip::File) } ],
            ['constant', lambda { defined?(Zip::Archive) }]
          ]
        }
      ]
    ]

    # attr_reader :backend
    def initialize(filename, options = {})
      if b = options.delete(:backend)
        @backend = b.to_sym
      end
    end

    def backend
      @backend ||= default_backend
    end

    def backend=(backend_name)
      if BACKENDS.map(&:first).include?(backend_name.to_sym)
        @backend = backend_name
      else
        raise NoSupportedBackendError, "Not a supported backend. Supported backends are #{BACKENDS.map(&:first).map(&:to_s).sort.join(', ')}"
      end
    end

  private

    def default_backend
      BACKENDS.each do |name, opts|
        if opts[:fingerprints].all?{|expectation, lmb| lmb.call == expectation }
          return name
        end
      end
      raise NoSupportedBackendError, "No supported backend found: #{BACKENDS.map(&:first).map(&:to_s).sort.join(', ')}"
    end
  end
end