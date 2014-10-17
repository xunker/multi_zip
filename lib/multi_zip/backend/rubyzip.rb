module MultiZip::Backend::Rubyzip
  def read_member(member_filename, options = {})
    Zip::File.open(@filename) do |zip_file|
      zip_file.glob(member_filename).first.get_input_stream.read
    end
  end

  def list_members(prefix=nil, options={})
    Zip::File.open(@filename) do |zip_file|
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
end