module MultiZip::Backend::Rubyzip
  def read_file(entry_filename, options = {})
    Zip::File.open(@filename) do |zip_file|
      zip_file.glob(entry_filename).first.get_input_stream.read
    end
  end
end