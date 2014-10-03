module MultiZip::Backend::Zipruby
  def read_file(entry_filename, options = {})
    Zip::Archive.open(@filename) do |zip|
      zip.fopen(entry_filename).read
    end
  end
end