require 'multi_zip'

require 'pry'
require 'pry-byebug'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # This setting enables warnings. It's recommended, but in some cases may
  # be too noisy due to issues in dependencies.
  config.warnings = false

  config.order = :random

  Kernel.srand config.seed
end


def remove_constants
  zipruby = [:Archive, :BEST_COMPRESSION, :BEST_SPEED, :CHECKCONS, :CM_BZIP2, :CM_DEFAULT, :CM_DEFLATE, :CM_DEFLATE64, :CM_IMPLODE, :CM_PKWARE_IMPLODE, :CM_REDUCE_1, :CM_REDUCE_2, :CM_REDUCE_3, :CM_REDUCE_4, :CM_SHRINK, :CM_STORE, :CREATE, :DEFAULT_COMPRESSION, :EM_NONE, :EM_TRAD_PKWARE, :EXCL, :Error, :FL_COMPRESSED, :FL_NOCASE, :FL_NODIR, :FL_UNCHANGED, :File, :NO_COMPRESSION, :Stat, :TRUNC, :VERSION]
  rubyzip = [:CDIR_ENTRY_STATIC_HEADER_LENGTH, :CENTRAL_DIRECTORY_ENTRY_SIGNATURE, :CentralDirectory, :CompressionMethodError, :Compressor, :DOSTime, :Decompressor, :Deflater, :DestinationFileExistsError, :Entry, :EntryExistsError, :EntryNameError, :EntrySet, :Error, :ExtraField, :FILE_TYPE_DIR, :FILE_TYPE_FILE, :FILE_TYPE_SYMLINK, :FSTYPES, :FSTYPE_ACORN, :FSTYPE_AMIGA, :FSTYPE_ATARI, :FSTYPE_ATHEOS, :FSTYPE_BEOS, :FSTYPE_CPM, :FSTYPE_FAT, :FSTYPE_HPFS, :FSTYPE_MAC, :FSTYPE_MAC_OSX, :FSTYPE_MVS, :FSTYPE_NTFS, :FSTYPE_QDOS, :FSTYPE_TANDEM, :FSTYPE_THEOS, :FSTYPE_TOPS20, :FSTYPE_UNIX, :FSTYPE_VFAT, :FSTYPE_VMS, :FSTYPE_VM_CMS, :FSTYPE_Z_SYSTEM, :File, :IOExtras, :Inflater, :InputStream, :InternalError, :LOCAL_ENTRY_SIGNATURE, :LOCAL_ENTRY_STATIC_HEADER_LENGTH, :LOCAL_ENTRY_TRAILING_DESCRIPTOR_LENGTH, :NullCompressor, :NullDecompressor, :NullInputStream, :OutputStream, :PassThruCompressor, :PassThruDecompressor, :RUNNING_ON_WINDOWS, :StreamableDirectory, :StreamableStream, :VERSION_MADE_BY, :VERSION_NEEDED_TO_EXTRACT, :VERSION_NEEDED_TO_EXTRACT_ZIP64, :ZipCompressionMethodError, :ZipDestinationFileExistsError, :ZipEntryExistsError, :ZipEntryNameError, :ZipError, :ZipInternalError] 

  if defined?(Zip)
    (zipruby + rubyzip).each do |cc|
      if Zip.constants.include?(cc)
        Zip.send(:remove_const, cc)
      end
    end
  end
end
