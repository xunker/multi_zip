class MultiZip
  class BaseError < RuntimeError;
    def to_s
      if respond_to?(:message)
        message
      else
        super
      end
    end
  end

  class NoSupportedBackendError < BaseError;
    def message
      "No supported backend found. Supported backends are #{MultiZip::BACKENDS.map(&:first).map(&:to_s).sort.join(', ')}"
    end
  end

  class InvalidBackendError < BaseError;
    attr_reader :requested_backend
    def initialize(requested_backend)
      @requested_backend = requested_backend
    end
    def message
      "The requested backend \"#{@requested_backend}\" was not found. Supported backends are #{MultiZip::BACKENDS.map(&:first).map(&:to_s).sort.join(', ')}"
    end
  end

  class ArchiveError < BaseError
    attr_reader :archive_filename, :original_exception
    def initialize(archive_filename, original_exception=nil)
      @archive_filename = archive_filename
      @original_exception = original_exception
    end
    def message
      "Archive \"#{@archive_filename}\" error: #{@original_exception.message}"
    end
  end

  class UnknownError < ArchiveError; end

  class InvalidArchiveError < ArchiveError; end
  class ArchiveNotFoundError < ArchiveError
    def message
      "Archive \"#{@archive_filename}\" not found"
    end
  end

  class MemberError < BaseError
    attr_reader :member_path
    def initialize(member_path)
      @member_path = member_path
    end
  end

  class MemberNotFoundError < MemberError
    def message
      "Member \"#{@member_path}\" not found."
    end
  end
end
