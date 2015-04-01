# MultiZip

Provides a standard, generic interface for zipping/unzipping files using
whatever gems are present on the system.

This lets you to avoid namespace collisions or implementation restrictions
in order to make your code more portable.

MultiZip provides a very small, very focused set up functions:

 * Create new archives.
 * Add members to a archive from variable content or the file-system.
 * Read members from a archive in to a variable.
 * Extract members from an archive to the file-system.
 * Delete members from an archive.
 * List members inside an archive and get information for a single member.

It is meant to to do the most common zip/unzip tasks. For anything more
complicated, using a specific (un)zipping library is recommended.

## Installation

Do the standard dance: Either add it to your `Gemfile` and `bundle install`
or `gem install multi_zip`.

__IMPORTANT NEXT STEP:__ You will also need a zip backend gem installed and
required. See `Supported Backends` for of which ones can be used.

## Usage

`multi_zip` will try to use the available backends in the following order:

  * rubyzip
  * zipruby

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

#### list files in a zip archive

Response array of file names within the archive.

```ruby
zip.list_members
# => [
  '/path/inside/archive/to/file_1.txt',
  '/path/inside/archive/to/file_2.txt'
]
```

#### Other

`.open` can also receive a block:

```ruby
MultiZip::File.open('/path/to/archive.zip') do |archive|
  # commands
end
```

## Supported backends

### Current

  * rubyzip
  * zipruby

### Pending

  * archive
  * archive-zip
  * minizip

## TODO

  * Standardize Exception classes and when to raise them

## Contributing

1. Fork it ( https://github.com/xunker/multi_zip/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
