require 'spec_helper'
require_relative 'backend_shared_example'

RSpec.describe MultiZip::File do
  let(:filename) { fixture_zip_file }
  let(:subject) { MultiZip::File.new(filename) }

  describe '.open' do
    it 'calls .new with same args' do
      options = { :foo => :bar }
      expect(MultiZip::File).to receive(:new).with(filename, options)
      MultiZip::File.open(filename, options)
    end
  end

  describe '#read_member' do
    [ %w[rubyzip zip], %w[zipruby zipruby] ].each do |backend_name, require_name|
      context "backend: #{backend_name}" do
        before do
          apply_constants(backend_name)
          subject.backend = backend_name
        end
        after { stash_constants(backend_name) }
        it 'returns the file as a string' do
          expect(
            subject.read_member('OEBPS/text/book_0002.xhtml').bytesize
          ).to eq(13_103)
        end
      end
    end
  end

  describe '#read_members' do
    [ %w[rubyzip zip], %w[zipruby zipruby] ].each do |backend_name, require_name|
      context "backend: #{backend_name}" do
        before do
          apply_constants(backend_name)
          subject.backend = backend_name
        end
        after { stash_constants(backend_name) }
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
  end

  describe '#list_members' do
    [ %w[rubyzip zip], %w[zipruby zipruby] ].each do |backend_name, require_name|
      context "backend: #{backend_name}" do
        before do
          apply_constants(backend_name)
          subject.backend = backend_name
        end
        after { stash_constants(backend_name) }
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
  end

  describe '#member_exists?' do
    [ %w[rubyzip zip], %w[zipruby zipruby] ].each do |backend_name, require_name|
      context "backend: #{backend_name}" do
        before do
          apply_constants(backend_name)
          subject.backend = backend_name
        end
        after { stash_constants(backend_name) }
        it 'is true if member exists' do
          expect(subject.member_exists?('mimetype')).to be_truthy
        end
        it 'is false if member does not exist' do
          expect(subject.member_exists?('does_not_exist')).to be_falsey
        end
      end
    end
  end

  describe '#write_member' do
    [ %w[rubyzip zip], %w[zipruby zipruby] ].each do |backend_name, require_name|
      context "backend: #{backend_name}" do
        before do
          apply_constants(backend_name)
          subject.backend = backend_name
        end
        after { stash_constants(backend_name) }
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

  describe '#write_members'

  describe '#add_member'

  describe '#add_members'

  describe '#backend=' do
    context 'supported backends' do
      before do
        # so we don't get NoSupportedBackendError in subject.
        expect_any_instance_of(MultiZip::File).to receive(:default_backend)
      end

      %w[ rubyzip zipruby ].each do |backend_name|
        it "sets backend to #{backend_name}" do
          subject.backend = backend_name
          expect(subject.backend).to eq(backend_name.to_sym)
        end
      end
    end

    context 'unknown backend' do
      it 'raises exception' do
        expect(
          lambda { subject.backend = 'unsupported' }
        ).to raise_exception(MultiZip::NoSupportedBackendError)
      end
    end
  end

  describe "#backend" do
    context "no backend specified" do
      [ %w[ zipruby zipruby ], %w[ rubyzip zip ] ].each do |gem_name, require_name|
        context "#{gem_name} gem has been required" do
          before do
            apply_constants(gem_name)
          end

          after { stash_constants(gem_name) }

          it "is :#{gem_name}" do
            expect(subject.backend).to eq(gem_name.to_sym)
          end

        end
      end
    end
  end
end