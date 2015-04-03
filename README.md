[![Build Status](https://travis-ci.org/xunker/multi_zip.png?branch=master)](https://travis-ci.org/xunker/multi_zip)
# [MultiZip](https://github.com/xunker/multi_zip)

MultiZip is a Ruby Gem that abstracts other zipping/unzipping gems. It
automatically detects what gems are available and provides a consistent
interface regardless of which is being used. This allows for code that is more
portable and helps to avoid namespace collisions (zipruby vs. rubyzip for example)
and other implementation restrictions (MRI vs. Jruby, Unix vs. Windows, etc,).

It currently supports `.zip` archives only. See TODO for info on others.

MultiZip provides a very small and focused set of functions:

 * Create a new zip archive or open existing one.
 * Add files to a archive from using content from a variable.
 * Add a local file to an archive. (Pending TODO).
 * Read files from a archive in to a variable.
 * Extract files from an archive to a local file.
 * List files contained in an archive.
 * Get information for a file in an archive. (Pending TODO)
 * Delete files from an archive. (Pending TODO)

It is meant for most common zip/unzip tasks. For anything more
complicated than these basics, you should use a specific (un)zipping library
instead.

Rubies supported (see [CI status](https://travis-ci.org/xunker/multi_zip) for more detail):
  * MRI 2.x.x, 1.9.3, 1.8.7 and REE.
  * Jruby
  * Rubinius 2

For information about which backend gems work in which ruby, see [Supported Backend Gems](#supported-backend-gems).

This work was inspired by [multi_json](https://github.com/intridea/multi_json)
and [multi_xml](https://github.com/sferik/multi_xml). The first version was
written while I was visiting Japan in 2014 and is dedicated to all the
rubyists I met there.

## Installation

Do the standard dance: Either add `gem 'multi_zip'` to your Gemfile or run
`gem install multi_zip`.

__IMPORTANT NEXT STEP:__ You will also need a zip backend gem installed and
required. See `Supported Backends` for of which ones can be used.

## Getting started

`multi_zip` will try to use the available gem backends in the following order:

  * rubyzip
  * archive/zip
  * zipruby

If no usable backends are loaded a `MultiZip::NoSupportedBackendError` will be
raised for any operation.

If you have multiple gems available and want to choose your backend, you can
do that in the initializer:

```ruby
zip = MultiZip.new(filename, backend: :rubyzip) }
```

..or by calling `#backend=` on a MultiZip instance:

```ruby
zip = MultiZip.new(filename)
zip.backend = :rubyzip
```

You can see what backends are supported:

```ruby
> MultiZip.supported_backends
 => [:rubyzip, :archive_zip, :zipruby]
```

You can also check which of these supported backends is currently available:

```ruby
> MultiZip.available_backends
 => [] 
> require 'archive/zip'
 => true 
> MultiZip.available_backends
 => [:archive_zip] 
> require 'zip'
 => true 
> MultiZip.available_backends
 => [:rubyzip, :archive_zip]
```

### Examples

For all the examples below, assume this:
```ruby
zip = MultiZip.new('/path/to/archive.zip')
```

#### Read file from zip archive

```ruby
file = zip.read_member('/path/inside/archive/to/file.txt')
# => "This is the content of the file from the archive."
```

Will raise `MultiZip::MemberNotFoundError` if the file can't be found.

#### Read multiple files from zip archive

```ruby
files = zip.read_member(
  '/path/inside/archive/to/file_1.txt',
  '/path/inside/archive/to/file_2.txt'
)
# => ["File one content.", "File two content."]
```

Will raise `MultiZip::MemberNotFoundError` if one or more of the files can't
be found.

#### Extract file from zip archive to filesystem path

```ruby
file = zip.extract_member(
  '/path/inside/archive/to/file.txt',
  'path/on/local/filesystem/file.txt'
)
# => 'path/on/local/filesystem/file.txt'
```

Will raise `MultiZip::MemberNotFoundError` if the file can't be found.

#### Write file to zip archive from string

```ruby
zip.write_member('/path/inside/archive/to/file.txt', 'File one content.')
# => true
```

#### List files in a zip archive

Response array of file names within the archive.

```ruby
zip.list_members
# => [
#  '/path/inside/archive/to/file_1.txt',
#  '/path/inside/archive/to/file_2.txt'
# ]
```

#### Creating a new instance and passing a block 

`.new` can accept a block:

```ruby
MultiZip.new('/path/to/archive.zip') do |archive|
  # commands
end
```

## Supported backend gems

  * [rubyzip](https://rubygems.org/gems/rubyzip)
    - Works in MRI 1.9.3 and 2.x.x.
    - Gem doesn't support MRI 1.8.7, Jruby or Rubinius.
  * [archive-zip](https://rubygems.org/gems/archive-zip)
    - Works in all MRI, Jruby and Rubinius.
  * [zipruby](https://rubygems.org/gems/zipruby)
    - Works in all MRI.
    - Gem doesn't support Jruby or Rubinius.

Planned for the future:

  * [archive](https://rubygems.org/gems/archive)
  * [unix_utils](https://rubygems.org/gems/unix_utils)
  * Other archive formats like gzip, bzip2, 7zip, tar, etc.
  * Jruby-specific gems
  * Others (please suggest them in a [new issue](https://github.com/xunker/multi_zip/issues/new))

## Notes

#### No `#close` method?

You'll notice that there is no `#close` method. All instance methods will open
the archive, perform the operation and then close it. The archive is not
opened or accessed until a method it called in the instance, and the archive
is not kept open between method calls.

#### Support for other Rubies

Supporting MRI, Jruby and Rubinius covers 95% of the production-ruby market.
However, In the future I plan on **trying** to support:

  * maglev
  * ironruby
  * macruby
  * [kiji](https://github.com/twitter-forks/rubyenterpriseedition187-248)

Currently I have travis-ci only testing on Linux. Adding macruby support also
means testing on OS X. I would like to one-day test with MRI and Ironruby on
Windows.

MultiZip is written in pure ruby and so it should be able to run on any
runtime that is compatible with MRI 1.8.7; however, the backend gems it uses
may or may not work on every platform -- which is part of the reason I made
this gem in the first place! One day I would like to support backend gems that
are specific to Jruby/Java and Windows.
  
## TODO

Things that need to be done, in no particular order:

  * Add inline docs for methods.
  * Add support for more backends.
  * Support for backend gems to process other formats (gzip, bzip2, 7zip, tar, etc).
  * Option to overwrite and existing archive instead of adding to it.
  * #write_member: support for reading from IO streams.
  * test with different majour versions of current supported backends.
  * Standardize Exception classes and when to raise them.
  * #read_*, #extract_* and #write_* methods should accept a block.
  * #extract_members: extract multiple files with one command (new method).
  * #extract_member: extract file to path using original member name.
  * #write_member: add entire directory (recursively or not) to archive.
  * #write_members: add multiple files by wildcard (new method).
  * #add_member: add file to archive from filesystem (new method).
  * #add_members: add multiple files to archive from filesystem (new method).
  * #remove_member: remove a member file from the archive (new_method).
  * #remove_members: remove multiple member files from the archive (new_method).
  * #read_members: read multiple files wildcard.
  * #read_members: read multiple files via prefix as #list_members does.
  * #extract_members: extract multiple files via prefix as #list_members does (new method).
  * #extract_members: extract multiple files wildcard (new method).
  * #member_info: return information (name, size, etc) about member (new method).
  * #read_member_stream: return member as IO Stream to keeping large amounts of data in memory (new method).
  * Write guide to show others how they can add their own backends gems.
  * #member_type: return the type of the member (new method).
  * #member_exists?: accept an argument to specify the file type (file, dir, symlink, etc).
  * Soak-test each backend to find memory leaks.

Things that I'd **like** to do, but that are probably not realistic because
they cannot be sufficiently abstracted across all backend gems:

  * Ability to set location and compression format and level of archive.
  * Ability to set compression format and level of individual members (for Epub compatibility).
  * Ability to set archive location of individual members (for Epub compatibility).
  * Support creating, reading from and writing to password-protected or encrypted archives.

## Contributing

1. Fork it ( https://github.com/xunker/multi_zip/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Ensure existing tests pass and add tests to cover any new functionality
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
