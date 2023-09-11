require 'rails_helper'

RSpec.describe FileUpload::LocalFileUploader do
  describe '#perform_save' do
    context 'saves file' do
      let(:output) { subject.save(fixture_file_upload('test.json', 'application/json')) }

      before do
        allow(File).to receive(:directory?).and_call_original
        allow(File).to receive(:directory?).with(Rails.root.join('tmp/uploaded/').to_s).and_return(false)
      end

      after do
        FileUtils.rm output
      end

      it 'stores in in the tmp directory' do
        expect(File).to be_file(output)
      end
    end
  end

  describe '#perform_destroy' do
    context 'development environment' do
      before do
        FileUtils.cp Rails.root.join('spec/fixtures/files/test.png'), Rails.root.join('spec/fixtures/files/12345')
      end

      it 'removes the file from tmp directory' do
        subject.destroy(Rails.root.join('spec/fixtures/files/12345'))
        expect(File).not_to be_file(Rails.root.join('spec/fixtures/files/12345'))
      end
    end
  end
end
