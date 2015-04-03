module MultiZip::Backend::ArchiveZip
  BUFFER_SIZE = 8192

  def read_member(member_path, options = {})
    Archive::Zip.open(@filename) do |zip|
      if member = zip.find{|m| m.zip_path == member_path}
        return member.file_data.read.to_s
      else
        zip.close
        member_not_found!(member_path)
      end
    end
  end

  def list_members(prefix=nil, options={})
    Archive::Zip.open(@filename) do |zip|
      zip.entries.map(&:zip_path).select{|n|
        prefix ? n =~ /^#{prefix}/ : true
      }.sort
    end
  end

  def write_member(member_path, member_contents, options = {})
    # archive/zip is really focused on adding content from the file system so
    # instead of hacking around with a non-public API that may change in the
    # future, we will just use tempfiles and let it read from disk like the
    # documentation says.
    tempfile = Tempfile.new('multizip_member')
    tempfile.write(member_contents)
    tempfile.close
    
    zip = Archive::Zip.new(@filename, :w)
    new_entry = Archive::Zip::Entry.from_file(tempfile.path, :zip_path => member_path)
    zip.add_entry(new_entry)

    # From the docs: The #close method must be called in order to save any
    # modifications to the archive.  Due to limitations in the Ruby finalization
    # capabilities, the #close method is _not_ automatically called when this
    # object is garbage collected.  Make sure to call #close when finished with
    # this object.
    zip.close
    true
  ensure
    if defined?(tempfile)
      tempfile.delete
    end
  end

  def extract_member(member_path, destination_path, options = {}) 
    Archive::Zip.open(@filename) do |zip|
      if member = zip.find{|m| m.zip_path == member_path}
        output_file = ::File.new(destination_path, 'wb')
        while chunk = member.file_data.read(BUFFER_SIZE)
          output_file.write chunk
        end
        output_file.close
        return destination_path
      else
        zip.close
        member_not_found!(member_path)
      end
    end
  end
end