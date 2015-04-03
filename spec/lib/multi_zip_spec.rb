require 'spec_helper'

RSpec.describe MultiZip do
  let(:filename) { archive_fixture_filename }
  let(:subject) { MultiZip.new(filename) }

  describe '.open' do
    it 'calls .new with same args' do
      options = { :foo => :bar }
      expect(MultiZip).to receive(:new).with(filename, options)
      MultiZip.open(filename, options)
    end
  end

  describe '#backend=' do
    context 'supported backends' do
      before do
        # so we don't get NoSupportedBackendError in subject.
        expect_any_instance_of(MultiZip).to receive(:default_backend)
      end

      backends_to_test.each do |backend_name|
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
      backends_to_test.each do |gem_name|
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