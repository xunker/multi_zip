module MultiZip::Backend::ArchiveZip
  BUFFER_SIZE = 8192

  def read_member(member_path, options = {})
    archive_operation do |zip|
      member = zip.find{|m| m.zip_path == member_path}
      if member && member.file?
        return member.file_data.read.to_s
      else
        zip.close
        member_not_found!(member_path)
      end
    end
  end

  def list_members(prefix=nil, options={})
    archive_operation do |zip|
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
    archive_operation do |zip|
      member = zip.find{|m| m.zip_path == member_path}
      if member && member.file?
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

  def remove_member(member_path, options = {})
    exists!(member_path)
    archive_operation(:w) do |zip|
      # I don't like mucking around with the guts like this, but recent
      # versions of Archive::Zip have lost #remove_entry. The only other
      # realistic option is to extract the entire archive to disk and then
      # recreate without member_path; that may be worse...
      warn 'Using non-public API to remove member using Archive::Zip'
      zip.instance_eval { @entries.reject!{|m| m.zip_path == member_path} }
    end
    true
  end

private

  def archive_operation(mode = :r) # mode is either :r or :w
    Archive::Zip.open(@filename, mode) do |zip|
      yield(zip)
    end
  rescue Archive::Zip::UnzipError => e
    raise MultiZip::InvalidArchiveError.new(@filename, e)
  end
end