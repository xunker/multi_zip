module MultiZip::Backend::Zipruby
  BUFFER_SIZE = 8192
  def read_member(member_path, options = {})
    Zip::Archive.open(@filename) do |ar|
      ar.fopen(member_path) {|member| member.read}
    end
  end

  def list_members(prefix=nil, options={})
    Zip::Archive.open(@filename) do |zip|
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
    Zip::Archive.open(@filename) do |ar|
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
end