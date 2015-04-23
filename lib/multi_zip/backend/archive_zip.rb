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
    remove_members([member_path], options)
  end

  def remove_members(member_paths, options = {})
    archive_exists!
    member_paths.each do |member_path|
      exists!(member_path)
    end
    
    # archive-zip doesn't have the #remove_entry method any more, so we do
    # this in a really slow way: we dump the entire dir to the filesystem,
    # delete `member_path` and zip the whole thing up again.
    
    Dir.mktmpdir do |tmp_dir|
      Archive::Zip.extract(@filename, tmp_dir)

      member_paths.each do |member_path|
        FileUtils.rm("#{tmp_dir}/#{member_path}")
      end
      
      # create a tempfile and immediately delete it, we just want the name.
      tempfile = Tempfile.new(['multizip_temp', '.zip'])
      tempfile_path = tempfile.path
      tempfile.close
      tempfile.delete

      Archive::Zip.archive(tempfile_path, "#{tmp_dir}/.")
      FileUtils.mv(tempfile_path, @filename)
    end

    true
  end

private

  def archive_operation(mode = :r) # mode is either :r or :w
    archive_exists!
    Archive::Zip.open(@filename, mode) do |zip|
      yield(zip)
    end
  rescue Archive::Zip::UnzipError => e
    raise MultiZip::InvalidArchiveError.new(@filename, e)
  end
end