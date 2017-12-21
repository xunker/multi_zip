## MultiZip TODO

#### Most important things, in order of importance:

  * #add_member: add file to archive from filesystem (new method).
  * Document exceptions raised, what they mean and how to use them.
  * Add inline docs for methods, in PROPER format.
  * Return zip members as objects, move all member-level methods there. Ex:
    ```ruby
      # A call like this:

      file = zip.read_member('/path/inside/archive/to/file.txt')
      # => "This is the content of the file from the archive."

      # ..would change in to this:
      member = zip.find('/path/inside/archive/to/file.txt')
      file = member.read
      # => "This is the content of the file from the archive."
      size = member.size
      # => 49
      ```
  * Travis-CI testing on more platforms and operating systems, with special
    attention to command-line zip/unzip compatibility. Most important:
    - Mac OS X
    - Windows (installing zip/unzip may be tricky?)
    - *BSD

#### Other things that need to be done, in no particular order:

  * Add support for more backends.
  * Option to keep the backend archive open between method calls.
    - Necessitates automatically calling #close when instance leaves scope.
  * Add soak tests for memory usage once archived are kept open.
  * Ensure #close is executed when MultiZip instance goes out of scope.
  * Option to overwrite and existing archive instead of adding to it.
  * #extract_member: extract file to path using original member name.
  * #write_member: support for reading from IO streams.
  * test with different majour versions of current supported backends.
  * Standardize Exception classes and when to raise them, and document it.
  * #read_*, #extract_* and #write_* methods should accept a block.
  * #extract_members: extract multiple files with one command (new method).
  * #write_member: add entire directory (recursively or not) to archive.
  * #write_members: add multiple files by wildcard (new method).
  * #add_members: add multiple files to archive from filesystem (new method).
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

#### Things that I'd **like** to do, but won't.

These are thinks that would be really nice to have but that are probably not
realistic because they cannot be abstracted across all backend gems and systems:

  * Support for backend gems to process other formats (gzip, bzip2, 7zip, tar, etc).
  * Ability to set location and compression format and level of archive.
  * Ability to set compression format and level of individual members (for Epub compatibility).
  * Ability to set archive location of individual members (for Epub compatibility).
  * Support creating, reading from and writing to password-protected or encrypted archives.
  * Support MagLev, IronRuby and MacRuby.
