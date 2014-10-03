require 'spec_helper'
require_relative 'backend_shared_example'

RSpec.describe MultiZip::File do
  let(:filename) { 'spec/fixtures/mymedia_lite-20130621.epub' }
  let(:subject) { MultiZip::File.new(filename) }

  before { puts 'remove'; remove_constants }

  describe '.open' do
    it 'calls .new with same args' do
      options = { :foo => :bar }
      expect(MultiZip::File).to receive(:new).with(filename, options)
      MultiZip::File.open(filename, options)
    end
  end

  describe '#read_file' do
    [ %w[rubyzip zip], %w[zipruby zipruby] ].each do |backend_name, require_name|
      context "backend: #{backend_name}" do
        before do
          puts "require \"#{require_name}\""
          puts require require_name
          subject.backend = backend_name
        end
        it 'returns the file as a string' do
          expect(
            subject.read_file('OEBPS/text/book_0002.xhtml').bytesize
          ).to eq(13_103)
        end
      end
    end
  end

  describe '#backend=' do
    context 'supported backends' do
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
            puts "require \"#{require_name}\""
            puts require(require_name)
          end

          it "is :#{gem_name}" do
            expect(subject.backend).to eq(gem_name.to_sym)
          end

        end
      end
    end
  end
end