module MultiZip::Backend::Rubyzip
  BUFFER_SIZE = 8192
  def read_member(member_path, options = {})
    read_operation do |zip_file|
      if member = zip_file.glob(member_path).first
        member.get_input_stream.read
      else
        zip_file.close
        member_not_found!(member_path)
      end
    end
  end

  def list_members(prefix=nil, options={})
    read_operation do |zip_file|
      zip_file.map(&:name).select{|n| prefix ? n =~ /^#{prefix}/ : true}.sort
    end
  end

  def write_member(member_path, member_contents, options = {})
    flags = (File.exists?(@filename) ? nil : Zip::File::CREATE)

    Zip::File.open(@filename, flags) do |zipfile|
      zipfile.get_output_stream(member_path) do |os|
        os.write member_contents
      end
    end
  end

  def extract_member(member_path, destination_path, options = {})
    read_operation do |zip_file|
      if member = zip_file.glob(member_path).first
        stream = member.get_input_stream

        output_file = ::File.new(destination_path, 'wb')

        while chunk = stream.read(BUFFER_SIZE)
          output_file.write chunk
        end

        output_file.close
      else
        zip_file.close
        member_not_found!(member_path)
      end
    end
    destination_path
  end

  def remove_member(member_path, options = {})
    exists!(member_path)
    Zip::File.open(@filename) do |zipfile|
      zipfile.remove(member_path)
    end
  end

private

  def read_operation(&blk)
    Zip::File.open(@filename) do |zip_file|
      yield(zip_file)
    end
  rescue Zip::Error => e
    # not the best way to detect the class of error.
    if e.message.match('Zip end of central directory signature not found')
      raise MultiZip::InvalidArchiveError.new(@filename, e)
    else
      raise
    end
  end
end