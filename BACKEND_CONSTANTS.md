# rubyzip

```ruby
> require 'zip'
 => true
> Zip.constants
 => [:DOSTime, :IOExtras, :Entry, :ExtraField, :EntrySet, :CentralDirectory, :File, :InputStream, :OutputStream, :Decompressor, :Compressor, :NullDecompressor, :NullCompressor, :NullInputStream, :PassThruCompressor, :PassThruDecompressor, :Inflater, :Deflater, :StreamableStream, :StreamableDirectory, :RUNNING_ON_WINDOWS, :CENTRAL_DIRECTORY_ENTRY_SIGNATURE, :CDIR_ENTRY_STATIC_HEADER_LENGTH, :LOCAL_ENTRY_SIGNATURE, :LOCAL_ENTRY_STATIC_HEADER_LENGTH, :LOCAL_ENTRY_TRAILING_DESCRIPTOR_LENGTH, :VERSION_MADE_BY, :VERSION_NEEDED_TO_EXTRACT, :VERSION_NEEDED_TO_EXTRACT_ZIP64, :FILE_TYPE_FILE, :FILE_TYPE_DIR, :FILE_TYPE_SYMLINK, :FSTYPE_FAT, :FSTYPE_AMIGA, :FSTYPE_VMS, :FSTYPE_UNIX, :FSTYPE_VM_CMS, :FSTYPE_ATARI, :FSTYPE_HPFS, :FSTYPE_MAC, :FSTYPE_Z_SYSTEM, :FSTYPE_CPM, :FSTYPE_TOPS20, :FSTYPE_NTFS, :FSTYPE_QDOS, :FSTYPE_ACORN, :FSTYPE_VFAT, :FSTYPE_MVS, :FSTYPE_BEOS, :FSTYPE_TANDEM, :FSTYPE_THEOS, :FSTYPE_MAC_OSX, :FSTYPE_ATHEOS, :FSTYPES, :Error, :EntryExistsError, :DestinationFileExistsError, :CompressionMethodError, :EntryNameError, :InternalError, :ZipError, :ZipEntryExistsError, :ZipDestinationFileExistsError, :ZipCompressionMethodError, :ZipEntryNameError, :ZipInternalError] 
```

# zipruby

```ruby
> require 'zipruby'
 => true
> Zip.constants
 => [:VERSION, :CREATE, :EXCL, :CHECKCONS, :TRUNC, :FL_NOCASE, :FL_NODIR, :FL_COMPRESSED, :FL_UNCHANGED, :CM_DEFAULT, :CM_STORE, :CM_SHRINK, :CM_REDUCE_1, :CM_REDUCE_2, :CM_REDUCE_3, :CM_REDUCE_4, :CM_IMPLODE, :CM_DEFLATE, :CM_DEFLATE64, :CM_PKWARE_IMPLODE, :CM_BZIP2, :EM_NONE, :EM_TRAD_PKWARE, :NO_COMPRESSION, :BEST_SPEED, :BEST_COMPRESSION, :DEFAULT_COMPRESSION, :Archive, :File, :Stat, :Error] 
```

# archive/zip

```ruby
> require 'archive/zip'
 => true
> Archive::Zip.constants
 => [:Codec, :DataDescriptor, :Error, :EntryError, :ExtraFieldError, :IOError, :UnzipError, :ExtraField, :Entry, :EOCD_SIGNATURE, :DS_SIGNATURE, :Z64EOCD_SIGNATURE, :Z64EOCDL_SIGNATURE, :CFH_SIGNATURE, :LFH_SIGNATURE, :DD_SIGNATURE] 
```
