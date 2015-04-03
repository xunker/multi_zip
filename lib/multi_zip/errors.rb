class MultiZip
  class BaseError < RuntimeError; end
  class NoSupportedBackendError < BaseError; end
  class MemberNotFoundError < BaseError
    def initialize(member_path)
      @member_path = member_path
    end
    def message
      "Member \"#{@member_path}\" not found."
    end
  end  
end