require 'spec_helper'
require_relative 'backend_shared_example'

RSpec.describe MultiZip::File do
  let(:filename) { 'spec/fixtures/mymedia_lite-20130621.epub' }
  let(:subject) { MultiZip::File.new(filename) }

  describe '#backend=' do
    context 'supported backends' do
      %w[ rubyzip zipruby ].each do |backend_name|
        it "sets backend to #{backend_name}" do
          subject.backend = backend_name
          expect(subject.backend).to eq(backend_name)
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
    context "no backend defined" do
      context "zipruby gem has been required" do
        before do
          remove_constants
          require 'zipruby'
        end

        it_behaves_like 'a backend', 'zipruby'

      end
      context "rubyzip gem has been required" do
        before do
          remove_constants
          require 'zip'
        end

        it_behaves_like 'a backend', 'rubyzip'
      end
    end
  end
end