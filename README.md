# MultiZip

Provides swappable zipping/unzipping backends utilizing zip/rubyzip, archive, archive-zip, minizip and zipruby.

## Installation

Do the standard dance: Either add it to your `Gemfile` and `bundle install`
or `gem install multi_zip`.

__IMPORTANT NEXT STEP:__ You will also need a zip backend gem installed and
required. See `Supported Backends` for of which ones can be used.

## Usage

`multi_zip` will try to use the available backends in the following order:

  * rubyzip
  * archive
  * archive-zip
  * zipruby
  * minizip

If no usable backends are loaded a `MultiZip::NoSupportedBackendError` will be
raised for any operation.

For all the examples below, assume this:
```ruby
zip = MultiZip::File.open('/path/to/archive.zip')
```

#### Read file from zip archive

```ruby
file = zip.read_member('/path/inside/archive/to/file.txt')
# => "This is the content of the file from the archive."
```

#### Read multiple files from zip archive

```ruby
files = zip.read_member('/path/inside/archive/to/file_1.txt', '/path/inside/archive/to/file_2.txt')
# => ["File one content.", "File two content."]
```

#### Write file to zip archive from string

```ruby
zip.write_member('/path/inside/archive/to/file.txt', 'File one content.')
# => true
```

#### Write multiple files to zip archive from strings

```ruby
zip.write_member(
  ['/path/inside/archive/to/file_1.txt', 'File one content.'],
  ['/path/inside/archive/to/file_2.txt', 'File two content.']
)
# => true
```

#### Add a file from filesystem to the zip archive

```ruby
zip.add_member('/path/inside/archive/to/file.txt', '/path/to/file.txt')
# => true
```

#### Add many files from the filesystem to the zip archive

```ruby
zip.add_members(
  ['/path/inside/archive/to/file_1.txt', '/path/to/file_1.txt'],
  ['/path/inside/archive/to/file_2.txt', '/path/to/file_2.txt']
)
# => true
```

#### Remove a file from the zip archive

```ruby
zip.remove_members('/path/inside/archive/to/file.txt')
# => true
```

#### Remove many files from the zip archive

```ruby
zip.remove_members(
  ['/path/inside/archive/to/file_1.txt', '/path/inside/archive/to/file_2.txt']
)
# => true
```

## Supported backends

  * rubyzip
  * archive
  * archive-zip
  * zipruby
  * minizip

## Contributing

1. Fork it ( https://github.com/xunker/multi_zip/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
