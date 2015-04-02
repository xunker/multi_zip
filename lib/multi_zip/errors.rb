class MultiZip
  class BaseError < RuntimeError
  end
  class NoSupportedBackendError < BaseError
  end
end