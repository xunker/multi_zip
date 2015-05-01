shared_examples 'zip backend' do |backend_name|
  context "backend: #{backend_name}" do
    let(:filename) { archive_fixture_filename }
    subject { MultiZip.new(filename, :backend => backend_name) }

    before do
      apply_constants(backend_name)
      # subject.backend = backend_name
    end
    after { stash_constants(backend_name) }

    describe '#read_member' do
      context 'member found' do
        archive_member_files.each do |member_file|
          it "returns '#{member_file}' as a string" do
            expect(
              subject.read_member(member_file).bytesize
            ).to eq(
              archive_member_size(member_file)
            )
          end
        end
      end

      context 'member not found' do
        it_behaves_like 'raises MemberNotFoundError', :read_member, 'doesnt_exist'
      end

      context 'member is a directory' do
        it_behaves_like 'raises MemberNotFoundError', :read_member, archive_member_directories.first
      end

      it_behaves_like 'archive not found, raises ArchiveNotFoundError', :read_member, archive_member_files.first

      context 'archive is not a file' do
        it 'raises ArchiveNotFoundError'
      end

      context 'archive cannot be accessed due to permissions' do
        it 'raises ArchiveNotAccessibleError'
      end

      context 'invalid or unreadable archive' do
        it_behaves_like 'raises InvalidArchiveError', :read_member, archive_member_files.first
      end
    end

    describe '#read_members' do
      context 'all members found' do
        it 'returns the member content as an array a string in order of args' do
          extracted_files = subject.read_members(archive_member_files)

          archive_member_files.each_with_index do |member, i|
            expect(extracted_files[i].bytesize).to eq(archive_member_size(member))
          end
        end
      end

      context 'one of the members is a directory' do
        it_behaves_like 'raises MemberNotFoundError', :read_members,
          [ archive_member_files.first, archive_member_directories.first ]
      end

      context 'one of the members is not found' do
        it_behaves_like 'raises MemberNotFoundError', :read_members,
          [ archive_member_files.first, 'doesnt_exist' ]
      end

      it_behaves_like 'archive not found, raises ArchiveNotFoundError', :read_members, archive_member_files
      
      context 'archive is not a file' do
        it 'raises ArchiveNotFoundError'
      end

      context 'archive cannot be accessed due to permissions' do
        it 'raises ArchiveNotAccessibleError'
      end

      context 'invalid or unreadable archive' do
        it_behaves_like 'raises InvalidArchiveError', :read_members,
          [ archive_member_files.first, archive_member_directories.first ]
      end
    end

    describe '#extract_member' do
      let(:tempfile) { Tempfile.new('multi_zip_test') }

      context 'member found' do
        let!(:extraction_return) { subject.extract_member(archive_member_files.first, tempfile.path) }
        after { tempfile.delete }
        it 'writes the file to the local filesystem' do
          expect(tempfile.size).to eq(archive_member_size(archive_member_files.first))
        end

        it 'returns the file system path written to' do
          expect(extraction_return).to eq(tempfile.path)
        end
      end

      context 'member is a directory' do
        it 'raises MemberNotFoundError' do
          expect(
            lambda { subject.extract_member(archive_member_directories.first, tempfile.path) }
          ).to raise_error(MultiZip::MemberNotFoundError)
        end
      end

      context 'member not found' do
        it 'raises MemberNotFoundError' do
          expect(
            lambda { subject.extract_member('doesnt_exist', tempfile.path) }
          ).to raise_error(MultiZip::MemberNotFoundError)
        end
      end

      it_behaves_like 'archive not found, raises ArchiveNotFoundError', :extract_member, archive_member_files.first, 'destination'
      
      context 'archive is not a file' do
        it 'raises ArchiveNotFoundError'
      end

      context 'archive cannot be accessed due to permissions' do
        it 'raises ArchiveNotAccessibleError'
      end

      context 'invalid or unreadable archive' do
        let(:filename) { invalid_archive_fixture_filename }
        it 'raises ArchiveInvalidError' do
          expect(
            lambda { subject.extract_member(archive_member_files.first, tempfile.path) }
          ).to raise_error(MultiZip::InvalidArchiveError)
        end
      end
    end

    describe '#list_members', focus: true do
      context 'file contains members' do
        it 'returns array member file names' do
          expect(subject.list_members).to eq(archive_member_names)
        end

        context 'prefix provided' do
          context 'files with that prefix exist' do
            it 'returns only files with that prefix' do
              expect(subject.list_members('dir_1/')).to eq(
                [ 'dir_1/', 'dir_1/file_3.txt' ]
              )
            end
          end

          context 'no files with that prefix exist' do
            it 'returns empty array' do
              expect(subject.list_members('doesnt_exist/')).to eq( [ ] )
            end
          end
        end
      end

      context 'contains no members, is empty archive' do
        it 'returns empty array'
      end

      it_behaves_like 'archive not found, raises ArchiveNotFoundError', :list_members
      
      context 'archive is not a file' do
        it 'raises ArchiveNotFoundError'
      end

      context 'archive cannot be accessed due to permissions' do
        it 'raises ArchiveNotAccessibleError'
      end

      context 'invalid or unreadable archive' do
        it_behaves_like 'raises InvalidArchiveError', :list_members
      end
    end

    describe '#member_exists?' do
      context 'member is a file' do
        it 'returns true if member exists' do
          expect(subject.member_exists?(archive_member_files.first)).to be_truthy
        end
      end

      context 'member is a directory' do
        it 'returns true if member exists' do
          expect(subject.member_exists?(archive_member_directories.first)).to be_truthy
        end
      end

      it 'returns false if member does not exist' do
        expect(subject.member_exists?('does_not_exist')).to be_falsey
      end

      it_behaves_like 'archive not found, raises ArchiveNotFoundError', :member_exists?, archive_member_files.first
      
      context 'archive is not a file' do
        it 'raises ArchiveNotFoundError'
      end

      context 'archive cannot be accessed due to permissions' do
        it 'raises ArchiveNotAccessibleError'
      end

      context 'invalid or unreadable archive' do
        it_behaves_like 'raises InvalidArchiveError', :member_exists?, archive_member_files.first
      end
    end

    describe '#write_member' do
      after { FileUtils.rm(filename) if File.exists?(filename) }

      let(:filename) { "/tmp/multizip_test.zip" }
      let(:member_file_name) { 'test_member_file' }
      let(:member_file_contents) { 'file contents here' }

      context 'archive did not exist' do
        before { expect(File.exists?(filename)).to be_falsey }
        
        let!(:result) do
          subject.write_member(member_file_name, member_file_contents)
        end

        it 'archive is created' do
          expect(File.exists?(filename)).to be_truthy
        end

        context 'member added successfully' do
          it 'returns true' do
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
          it 'raises MemberNotAddedError'
          it 'does not add member to the archive/archive is empty'
        end
      end

      context 'archive already exists' do
        before do
          FileUtils.cp(archive_fixture_filename, filename)
          expect(File.exists?(filename)).to be_truthy
        end

        let!(:preexisting_members) { subject.list_members }

        let!(:result) do
          subject.write_member(member_file_name, member_file_contents)
        end

        context 'member added successfully' do
          it 'returns true' do
            expect(result).to be_truthy
          end

          context 'member with that name already exists' do
            let(:member_file_name) { 'mimetype' }
            it 'returns true' do
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
          it 'raises MemberNotAddedError'
          it 'does not add member to the archive'
          it 'does not remove preexisting members from the archive'
        end
      end

      context 'archive is not a file' do
        it 'raises ArchiveNotFoundError'
      end

      context 'archive cannot be accessed due to permissions' do
        it 'raises ArchiveNotAccessibleError'
      end

      context 'invalid or unreadable archive' do
        it 'raises ArchiveInvalidError'
      end
    end

    describe '#remove_member' do
      subject { MultiZip.new(temp_filename, :backend => backend_name) }

      let(:temp_filename) { "/tmp/multizip_test.zip" }
      let(:member_file_name) { archive_member_files.first }

      after do
        FileUtils.rm(temp_filename) if File.exists?(temp_filename)
      end

      context 'archive exists' do
        before do
          FileUtils.cp(filename, temp_filename)
          expect(
            MultiZip.new(temp_filename).member_exists?(member_file_name)
          ).to be_truthy
        end
        
        let!(:result) do
          subject.remove_member(member_file_name)
        end

        context 'member removed successfully' do
          it 'returns true' do
            expect(result).to be_truthy
          end
          it 'removes the member from the file' do
            expect(
              MultiZip.new(temp_filename).member_exists?(member_file_name)
            ).to be_falsey
          end
          it 'does not remove any other members' do
            zip = MultiZip.new(temp_filename)
            (archive_member_files - [member_file_name]).each do |mfn|
              expect(zip.member_exists?(mfn)).to be_truthy
            end
          end
        end

        context 'member not successfully added' do
          it 'raises MemberNotRemovedError'
          it 'does not remove member from the archive'
        end
      end

      it_behaves_like 'archive not found, raises ArchiveNotFoundError', :remove_member, archive_member_files.first
      
      context 'archive is not a file' do
        it 'raises ArchiveNotFoundError'
      end

      context 'archive cannot be accessed due to permissions' do
        it 'raises ArchiveNotAccessibleError'
      end

      context 'invalid or unreadable archive' do
        it 'raises ArchiveInvalidError'
      end
    end  

    describe '#remove_members' do
      subject { MultiZip.new(temp_filename, :backend => backend_name) }

      let(:temp_filename) { "/tmp/multizip_test.zip" }
      let(:member_file_names) { archive_member_files[0..1] }

      after do
        FileUtils.rm(temp_filename) if File.exists?(temp_filename)
      end

      context 'archive exists' do
        before do
          FileUtils.cp(filename, temp_filename)
          member_file_names.each do |mfn|
            expect(
              MultiZip.new(temp_filename).member_exists?(mfn)
            ).to be_truthy
          end
        end
        
        let!(:result) do
          subject.remove_members(member_file_names)
        end

        context 'members removed successfully' do
          it 'returns true' do
            expect(result).to be_truthy
          end
          it 'removes the members from the file' do
            member_file_names.each do |mfn|
              expect(
                MultiZip.new(temp_filename).member_exists?(mfn)
              ).to be_falsey
            end
          end
          it 'does not remove any other members' do
            zip = MultiZip.new(temp_filename)
            (archive_member_files - member_file_names).each do |mfn|
              expect(zip.member_exists?(mfn)).to be_truthy
            end
          end
        end

        context 'member not successfully added' do
          it 'raises MemberNotRemovedError'
          it 'does not remove member from the archive'
        end
      end

      it_behaves_like 'archive not found, raises ArchiveNotFoundError', :remove_members, archive_member_files
      
      context 'archive is not a file' do
        it 'raises ArchiveNotFoundError'
      end

      context 'archive cannot be accessed due to permissions' do
        it 'raises ArchiveNotAccessibleError'
      end

      context 'invalid or unreadable archive' do
        it 'raises ArchiveInvalidError'
      end
    end  
  end
end

shared_examples 'raises MemberNotFoundError' do |*args|
  it 'raises MemberNotFoundError' do
    expect(lambda{ subject.send(args.shift, *args) }).to raise_error(MultiZip::MemberNotFoundError)
  end
end

shared_examples 'raises InvalidArchiveError' do |*args|
  let(:filename) { invalid_archive_fixture_filename }
  it 'raises InvalidArchiveError' do
    expect(lambda{ subject.send(args.shift, *args) }).to raise_error(MultiZip::InvalidArchiveError)
  end
end

shared_examples 'raises ArchiveNotFoundError' do |*args|
  it 'raises ArchiveNotFoundError' do
    expect(lambda{ subject.send(args.shift, *args) }).to raise_error(MultiZip::ArchiveNotFoundError)
  end
end

shared_examples 'archive not found, raises ArchiveNotFoundError' do |*args|
  context 'archive not found' do
    let(:filename) { 'doesnt_exist' }  
    it_behaves_like 'raises ArchiveNotFoundError', *args
  end
end