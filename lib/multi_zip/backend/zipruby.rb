module MultiZip::Backend::Zipruby
  BUFFER_SIZE = 8192
  def read_member(member_path, options = {})
    # detect if called asked for a directory instead of a file
    member_not_found!(member_path) if member_path =~ /\/$/
    read_operation do |ar|
      exists_in_archive!(ar, member_path)
      ar.fopen(member_path) {|member| member.read}
    end
  end

  def list_members(prefix=nil, options={})
    read_operation do |zip|
      list = []
      zip.num_files.times do |i|
        list << zip.get_name(i)
      end
      list.select{|n| prefix ? n =~ /^#{prefix}/ : true}.sort
    end
  end

  def write_member(member_path, member_contents, options = {})
    flags = (File.exists?(@filename) ? nil : Zip::CREATE)
    Zip::Archive.open(@filename, flags) do |ar|
      if ar.map(&:name).include?(member_path)
        ar.replace_buffer(member_path, member_contents)
      else
        ar.add_buffer(member_path, member_contents)
      end
    end
    true
  end

  def extract_member(member_path, destination_path, options = {})
    read_operation do |ar|
      exists_in_archive!(ar, member_path)
      output_file = ::File.new(destination_path, 'wb')

      ar.fopen(member_path) do |member|
        while chunk = member.read(BUFFER_SIZE)
          output_file.write chunk
        end
      end

      output_file.close
    end
    destination_path
  end

private
  # NOTE: Zip::Archive#locate_name return values
  # -1 if path not found
  # 0  if path is a directory
  # 2  if path is a file
  #
  # for a directory to be found it must include the trailing slash ('/').

  def exists_in_archive?(zip, member_path)
    zip.locate_name(member_path).to_i >= 0 # will find files or dirs.
  end

  def exists_in_archive!(zip, member_path)
    unless exists_in_archive?(zip, member_path)
      zip.close
      raise member_not_found!(member_path)
    end
  end

  def read_operation(&blk)
    Zip::Archive.open(@filename) do |ar|
      yield(ar)
    end
  rescue Zip::Error => e
    # not the best way to detect the class of error.
    if e.message.match('Not a zip archive')
      raise MultiZip::InvalidArchiveError.new(@filename, e)
    else
      raise
    end
  end
end