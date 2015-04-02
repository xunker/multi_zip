shared_examples 'zip backend' do |backend_name|
  let(:filename) { fixture_zip_file }
  let(:subject) { MultiZip::File.new(filename, backend: backend_name) }

  before do
    apply_constants(backend_name)
    # subject.backend = backend_name
  end
  after { stash_constants(backend_name) }

  describe '#read_member' do
    context "backend: #{backend_name}" do
      it 'returns the file as a string' do
        expect(
          subject.read_member('OEBPS/text/book_0002.xhtml').bytesize
        ).to eq(13_103)
      end
    end
  end

  describe '#read_members' do
    context "backend: #{backend_name}" do
      it 'returns the files as an array a string in order of args' do
        extracted_files = subject.read_members([
            'OEBPS/text/book_0000.xhtml',
            'OEBPS/text/book_0001.xhtml',
            'OEBPS/text/book_0002.xhtml'
        ])

        expect(extracted_files[0].bytesize).to eq(615)
        expect(extracted_files[1].bytesize).to eq(1_081)
        expect(extracted_files[2].bytesize).to eq(13_103)
      end
    end
  end

  describe '#extract_member' do
    context "backend: #{backend_name}" do
      let(:tempfile) { Tempfile.new('multi_zip_test') }
      let!(:extraction_return) { subject.extract_member('OEBPS/text/book_0002.xhtml', tempfile.path) }
      after { tempfile.delete }
      it 'writes the file to the local filesystem' do
        expect(tempfile.size).to eq(13_103)
      end

      it 'returns the file system path written to' do
        expect(extraction_return).to eq(tempfile.path)
      end
    end
  end

  describe '#list_members' do
    context "backend: #{backend_name}" do
      it 'returns array member file names' do
        expect(subject.list_members).to eq(
          [
            "META-INF/",
            "META-INF/container.xml",
            "OEBPS/",
            "OEBPS/images/",
            "OEBPS/images/akahata.jpg",
            "OEBPS/images/cover.jpg",
            "OEBPS/images/gari01.jpg",
            "OEBPS/images/gari02.jpg",
            "OEBPS/images/gari03.jpg",
            "OEBPS/images/tsuno.png",
            "OEBPS/images/yashima.jpg",
            "OEBPS/mymedia_lite.opf",
            "OEBPS/styles/",
            "OEBPS/styles/ebook_common.css",
            "OEBPS/styles/ebook_style.css",
            "OEBPS/styles/ebook_style_h.css",
            "OEBPS/styles/ebook_style_v.css",
            "OEBPS/text/",
            "OEBPS/text/book_0000.xhtml",
            "OEBPS/text/book_0001.xhtml",
            "OEBPS/text/book_0002.xhtml",
            "OEBPS/text/book_0003.xhtml",
            "OEBPS/text/book_0004.xhtml",
            "OEBPS/text/book_0005.xhtml",
            "OEBPS/text/book_0006.xhtml",
            "OEBPS/toc.xhtml",
            "mimetype"
          ]
        )
      end

      context 'prefix provided' do
        it 'returns only files with that prefix' do
          expect(subject.list_members('META-INF/')).to eq(
            [ "META-INF/", "META-INF/container.xml" ]
          )
        end
      end
    end
  end

  describe '#member_exists?' do
    context "backend: #{backend_name}" do
      it 'is true if member exists' do
        expect(subject.member_exists?('mimetype')).to be_truthy
      end
      it 'is false if member does not exist' do
        expect(subject.member_exists?('does_not_exist')).to be_falsey
      end
    end
  end

  describe '#write_member' do
    context "backend: #{backend_name}" do
      after { FileUtils.rm(filename) if File.exists?(filename) }

      let(:filename) { "/tmp/multizip_test.zip" }
      let(:member_file_name) { 'test_member_file' }
      let(:member_file_contents) { 'file contents here' }

      context 'zip file did not exist' do
        before { expect(File.exists?(filename)).to be_falsey }
        
        let!(:result) do
          subject.write_member(member_file_name, member_file_contents)
        end

        it 'is created' do
          expect(File.exists?(filename)).to be_truthy
        end
        context 'member added successfully' do
          it 'is true' do
            expect(result).to be_truthy
          end
          it 'adds the member to the file' do
            expect(
              subject.read_member(member_file_name)
            ).to eq(
              member_file_contents
            )
          end
        end
        context 'member not successfully added' do
          it 'is false'
          it 'member not added to the file'
          it 'populates #error'
        end
      end

      context 'zip file already exists' do
        before do
          FileUtils.cp(fixture_zip_file, filename)
          expect(File.exists?(filename)).to be_truthy
        end

        let!(:preexisting_members) { subject.list_members }

        let!(:result) do
          subject.write_member(member_file_name, member_file_contents)
        end

        context 'member added successfully' do
          it 'is true' do
            expect(result).to be_truthy
          end
          context 'member with that name already exists' do
            let(:member_file_name) { 'mimetype' }
            it 'is true' do
              expect(result).to be_truthy
            end
            it 'it overwrites the member file name with new data' do
              expect(
                subject.read_member(member_file_name)
              ).to eq(
                member_file_contents
              )
            end
          end
          it 'adds the member to the file' do
            expect(
              subject.read_member(member_file_name)
            ).to eq(
              member_file_contents
            )
          end
          it 'does not remove preexisting members' do
            expect(
              subject.list_members - preexisting_members
            ).to eq(
              [ member_file_name ]
            )
          end
        end

        context 'member not successfully added' do
          it 'is false'
          it 'member not added to the file'
          it 'does not remove preexisting members'
          it 'populates #error'
        end
      end
    end
  end  
end
