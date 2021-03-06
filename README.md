[![Build Status](https://travis-ci.org/xunker/multi_zip.png?branch=master)](https://travis-ci.org/xunker/multi_zip)
# [MultiZip](https://github.com/xunker/multi_zip)

MultiZip is a Ruby Gem that abstracts other zipping/unzipping gems. It
automatically detects what gems are available and provides a consistent
interface regardless of which is being used. This allows for code that is more
portable and helps to avoid namespace collisions (zipruby vs. rubyzip for example)
and other implementation restrictions (MRI vs. Jruby, Unix vs. Windows, etc,).

It currently supports `.zip` archives only.

MultiZip provides a very small and focused set of functions:

 * Create a new zip archive or open existing one.
 * Add files to an archive from a file a variable.
 * Read files from an archive in to a variable.
 * Extract files from an archive to a local file.
 * List files contained in an archive.
 * Delete files from an archive.

It is meant for most common zip/unzip tasks. For anything more
complicated than these basics, you should use a specific (un)zipping library
instead.

Rubies supported (see [CI status](https://travis-ci.org/xunker/multi_zip) for more detail):
  * MRI 2.x.x, 1.9.3, 1.8.7.
  * Jruby
  * Rubinius

For information about which backend gems work in which ruby, see [Supported Backend Gems](#supported-backend-gems).

This gem was inspired by [multi_json](https://github.com/intridea/multi_json)
and [multi_xml](https://github.com/sferik/multi_xml), and is dedicated to the
Rubyists of [Asukusa.rb](https://asakusarb.doorkeeper.jp/) and
[John Mettraux](https://twitter.com/jmettraux) of Hiroshima.
おもてなしのあなたはありがとう！

## Installation

Do the standard dance: Either add `gem 'multi_zip'` to your Gemfile or run
`gem install multi_zip`.

__IMPORTANT NEXT STEP:__ You will also need a zip backend gem installed and
required. See [Supported Backend Gems](#supported-backend-gems) for a list of
which ones can be used.

## Getting started

`multi_zip` will try to use the available gem backends in the following order:

  * [rubyzip](https://rubygems.org/gems/rubyzip)
  * [archive-zip](https://rubygems.org/gems/archive-zip)
  * [zipruby](https://rubygems.org/gems/zipruby)

If no usable gems are found, it will then look for a compatible `zip`/ `unzip`
program in your path and will try to use that instead of a gem. If no
compatible gems or program can be found, a `MultiZip::NoSupportedBackendError`
exception will be raised.

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

#### List files in a zip archive

Response array of file names within the archive.

```ruby
zip.list_members
# => [
#  '/path/inside/archive/to/file_1.txt',
#  '/path/inside/archive/to/file_2.txt'
# ]
```

#### Check if a file exists in an archive

Returns `true` if the file exists in the archive, otherwise `false`

```ruby
zip.member_exists?('/path/inside/archive/to/file.txt')
# => true

zip.member_exists?('/doesnt_exist')
# => false
```

#### Get member information (file size, etc)

Returns a hash if the file exists in the archive, otherwise will raise exception.

```ruby
zip.member_info('/path/inside/archive/to/file.txt')
# => { :path => '/path/inside/archive/to/file.txt', :size => 14323, type: :file }
```

At a minimum, the returned hash will contain:
  :path  the full path of the member file (should equal `member_path` arg)
  :size  the UNCOMPRESSED file size, in bytes

Optionally, it MAY contain these keys:
  :type             Filesystem type of the member (:directory, :file, :symlink, etc)
  :created_at       creation timestamp of the file as an instance of Time
  :compressed_size  size of the COMPRESSED file in bytes
  :original         The original member info object as returned from the backend
                    gem. Ex: using rubyzip, it would be an instace of Zip::Entry.

#### Read file from zip archive

```ruby
file = zip.read_member('/path/inside/archive/to/file.txt')
# => "This is the content of the file from the archive."
```

#### Read multiple files from zip archive

```ruby
files = zip.read_members([
  '/path/inside/archive/to/file_1.txt',
  '/path/inside/archive/to/file_2.txt'
])
# => ["File one content.", "File two content."]
```

#### Extract file from zip archive to filesystem path

```ruby
file = zip.extract_member(
  '/path/inside/archive/to/file.txt',
  'path/on/local/filesystem/file.txt'
)
# => 'path/on/local/filesystem/file.txt'
```

#### Write file to zip archive from string

```ruby
zip.write_member('/path/inside/archive/to/file.txt', 'File one content.')
# => true
```

#### Remove a file from a zip archive

```ruby
file = zip.remove_member('/path/inside/archive/to/file.txt')
# => true
```

#### Remove multiple files from a zip archive

```ruby
file = zip.remove_members([
  '/path/inside/archive/to/file_1.txt',
  '/path/inside/archive/to/file_2.txt'
])
# => true
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
    - Works in MRI 2.x.x.
    - Version 1.2.0 is the last that is compatible with MRI 1.9.3
    - Doesn't support MRI 1.8.7, Jruby or Rubinius.
  * [archive-zip](https://rubygems.org/gems/archive-zip)
    - Works in all MRI, Jruby and Rubinius.
  * [zipruby](https://rubygems.org/gems/zipruby)
    - Works in all MRI.
    - Gem doesn't support Jruby or Rubinius.
  * Command-line `zip` and `unzip` ("Info-ZIP" style)
    - This is not a gem, it is an always-included fallback that will allow the
      gem to work on any system that has Info-ZIP `zip` 3.00 and Info-ZIP
      `unzip` 6.0 command-line programs available.

    - Please note that this is currently *experimental* and should __not__ be
      used in mission-critical situations.

    - Platforms where this is available include:
        - Mac OS X (installed by default)
        - Most Linux'es
          - Ubuntu (default), including most Debian-based distros
          - RedHat (default), including AMI
        - FreeBSD
        - Windows
        - See [the Info-ZIP site](http://www.info-zip.org/) for complete list

Planned for the future:

  * [archive gem](https://rubygems.org/gems/archive)
  * Other archive formats like gzip, bzip2, 7zip, tar, etc.
  * Jruby-specific gems
  * Others (please suggest them in a [new issue](https://github.com/xunker/multi_zip/issues/new))

## Notes

#### No `#save` method?

You'll notice that there is no `#save` method. All changes are made to the
archive immediately when the given method is called. If there are errors
writing to an archive, an exception is raised immediately.

#### Archive objects are not kept open between method calls

The underlying archive object from the backend gem is not kept open open in
memory. That means when you call a method like `#read_member` the archive is
opened, the file is read and the archive is closed. If you do that method
twice, that cycle happens two times.

While this *is* inefficient and *may* be slow for large archives, the benefits are a simplified interface and normalized memory usage.

This behaviour is likely to change in future versions; see the below section
that talks about the `#close` method for more information.

#### `#close` method is currently a non-op

You'll notice that there is a `#close` method, but you may not know that it
doesn't yet do anything since the underlying archive is not kept open between
method calls.

However, you should still use `#close` where appropriate since this
behaviour is likely to change in the future.

#### Backend support on platforms

MultiZip is written in pure ruby and so it should be able to run on any
runtime that is compatible with MRI 1.8.7; however, the backend gems it uses
may or may not work on every platform -- which is one of the reasons this
gem exists in the first place!

## TODO

See [TODO.md](TODO.md).

## Contributing

1. Fork it ( https://github.com/xunker/multi_zip/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Ensure existing tests pass and add tests to cover any new functionality
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
