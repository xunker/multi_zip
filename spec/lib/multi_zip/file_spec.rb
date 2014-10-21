require 'spec_helper'

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