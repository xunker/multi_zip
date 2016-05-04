# If no suitable gems are found, this is the last-gasp fallback. We use
# whatever command-line zipping/unzipping tools we can find and that we
# know how to use.
#
# This will likely be a huge work in progress since it involves a lot of
# detection. We'll need to detect the host OS and version, the tools available
# in the path (or specified by the user, optionally) and the command-line
# arguments to be used for those tools.
#
# OS          Unzip                           Zip
#------------------------------------------------------------------------------
# OS X 10.10  Info-ZIP UnZip 5.52             Info-ZIP Zip 3.0
# RHEL-Based  Info-ZIP UnZip 5.xx to 6.xx     Info-ZIP Zip 2.x to 3.x
# Ubuntu      Info-ZIP UnZip 6.xx             Info-ZIP Zip 3.0
# Raspbian    Info-ZIP UnZip 6.00             Info-ZIP Zip 3.0
# Windows
#             GNU UnZip (from INFO-Zip UnZip) GNU Zip (from INFO-Zip Zip)
#             7-Zip Command Line Version      7-Zip Command Line Version
#             PKWare pkunzip                  PKWare pkzip
#             WinZip CLI                      WinZip CLI
#             WinRAR CLI                      WinRAR CLI
#
# First, check for the programs that would be installed by default.
# If none can be found, raise an error and tell the user how they can resolve
# the problem: Either tell them to install a different backend gem (preferred)
# or tell them how to install a supported CLI program (depending on OS).
#
# When using this shell method, always emit a warning that it is very
# inefficient and should not never no-way no-how no-where be used in
# production environments.

module MultiZip::Backend::Cli
  STRATEGY_MODULES = [
    [ :info_zip, lambda { InfoZip }]
  ]

  def self.extended(mod)
    if strategy_available?
      require "multi_zip/backend/cli/#{strategy.require_name}"
      extend strategy.extend_class.call
      warn([
        "MultiZip is using the \"#{strategy.human_name}\" command-line program.",
        'This feature is considered PRE-ALPHA, unstable and inefficient and',
        'should not be used in production environments.'
      ].join("\n"))
    else
      raise MultiZip::NoSupportedBackendError, "MultiZip::Backend::Cli could find no suitable zipping/unzipping programs in path."
    end
  end

  def self.strategy_available?
    !!strategy
  end

  def self.strategy
    @strategy ||= detect_strategy
  end

  def self.detect_strategy
    STRATEGY_MODULES.detect{|strategy_module_file, strategy_module_constant|
      require "multi_zip/backend/cli/#{strategy_module_file}"
      strategy_module = strategy_module_constant.call
      if strategy_module.available?
        return strategy_module
      end
    }
  end
end
