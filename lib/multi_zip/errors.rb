class MultiZip
  class BaseError < RuntimeError; end
  
  class NoSupportedBackendError < BaseError; end

  class ArchiveError < BaseError
    attr_reader :archive_filename, :original_exception
    def initialize(archive_filename, original_exception)
      @archive_filename = archive_filename
      @original_exception = original_exception
    end
    def message
      "Archive \"#{@archive_filename}\" error: #{@original_exception.message}"
    end
  end

  class InvalidArchiveError < ArchiveError; end

  class MemberError < BaseError
    attr_reader :member_path
    def initialize(member_path)
      @member_path = member_path
    end
    def message
      "Member \"#{@member_path}\" not found."
    end
  end

  class MemberNotFoundError < MemberError; end
end