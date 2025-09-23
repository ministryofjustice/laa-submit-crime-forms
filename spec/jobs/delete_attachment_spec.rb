require 'rails_helper'

RSpec.describe DeleteAttachment do
  subject { described_class.new }

  before do
    allow(File).to receive(:exist?).and_return(test_path == 'test_path')
    allow(FileUtils).to receive(:remove).with('test_path').and_return(true)
    allow(FileUtils).to receive(:remove).with('new_test_path').and_return(false)
  end

  describe '#perform' do
    context 'when the attachment exists' do
      let(:test_path) { 'test_path' }

      it 'is destroyed' do
        expect_any_instance_of(FileUpload::FileUploader).to receive(:destroy)

        subject.perform(test_path)
      end
    end

    context 'when the attachment does not exist' do
      let(:test_path) { 'new_test_path' }

      it 'is not destroyed' do
        expect_any_instance_of(FileUpload::FileUploader).not_to receive(:destroy)

        subject.perform(test_path)
      end
    end
  end
end
