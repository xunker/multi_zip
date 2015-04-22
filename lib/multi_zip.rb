class MultiZip
  module Backend; end # populated later by #extend

  attr_reader :filename

  BACKEND_PREFERENCE = [ :rubyzip, :archive_zip, :zipruby ]
  BACKENDS = {
    :rubyzip => {
      :fingerprints => [
        ['constant', lambda { defined?(Zip::File) } ],
        [nil, lambda { defined?(Zip::Archive) }]
      ],
      :constant => lambda { MultiZip::Backend::Rubyzip }
    },
    :archive_zip => {
      :fingerprints => [
        ['constant', lambda { defined?(Archive::Zip) } ]
      ],
      :constant => lambda { MultiZip::Backend::ArchiveZip }
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

  def self.supported_backends
    BACKENDS.keys
  end

  def self.available_backends
    available = []
    BACKENDS.each do |name, opts|
      if opts[:fingerprints].all?{|expectation, lmb| lmb.call == expectation }
        available << name
      end
    end
    available
  end

  # Close the archive, if the archive is open.
  # If the archive is already closed, behave as though it was open.
  # Expected to always return true.
  #
  # This is currently a non-op since the archives are not kept open between
  # method calls. It is here so users can write code using it to prepare for
  # when we *do* keep the archives open.
  #
  # Currently, this method MUST NOT be overridden.
  def close
    return true
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
  # This SHOULD be overridden by a backend module because this default
  # will try to read the whole file in to memory before outputting to disk
  # and that can be memory-intensive if the file is large.
  def extract_member(member_path, destination_path, options={})
    warn "Using default #extract_member which may be memory-inefficient"
    default_extract_member(member_path, destination_path, options)
  end

  # List members of the zip file. Optionally can specify a prefix.
  #
  # This method MUST be overridden by a backend module.
  def list_members(prefix = nil, options={})
    raise NotImplementedError
  end

  # Boolean, does a given member path exist in the zip file?
  #
  # This method MAY be overridden by backend module for the sake of
  # efficiency. Otherwise it will use #list_members.
  def member_exists?(member_path, options={})
    list_members(nil, options).include?(member_path)
  end

  # Write string contents to a zip member file
  def write_member(member_path, member_content, options={})
    raise NotImplementedError
  end

  # Remove a zip member from the archive.
  # Expected to raise MemberNotFoundError if the member_path was not found in
  # the archive
  #
  # This method MUST be overridden by a backend module.
  def remove_member(member_path, options={})
    raise NotImplementedError
  end

  # Remove multiple zip member from the archive.
  # Expected to raise MemberNotFoundError if the member_path was not found in
  # the archive
  #
  # This method MAY be overridden by backend module for the sake of
  # efficiency. Otherwise it will use #remove_member.
  def remove_members(member_paths, options={})
    member_paths.map{|f| remove_member(f, options) }.all?
  end

private

  # Convenience method that will raise ArchiveNotFoundError if the archive
  # doesn't exist or if the archive path given points to something other than
  # a file.
  def archive_exists!
    unless File.file?(@filename)
      raise ArchiveNotFoundError.new(@filename)
    end
  end

  # Convenience method that will raise MemberNotFoundError if the member doesn't exist.
  # Uses #member_exists? in whatever form (default or custom).
  def exists!(member_path)
    unless member_exists?(member_path)
      member_not_found!(member_path)
    end
    true
  end

  # Raises MemberNotFoundError
  def member_not_found!(member_path)
    raise MemberNotFoundError.new(member_path)
  end

  def default_extract_member(member_path, destination_path, options={})
    output_file = ::File.new(destination_path, 'wb')
    output_file.write(read_member(member_path, options))
    output_file.close
    destination_path
  end

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

require "multi_zip/version"
require "multi_zip/errors"
