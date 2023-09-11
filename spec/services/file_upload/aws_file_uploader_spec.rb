require 'rails_helper'

RSpec.describe FileUpload::AwsFileUploader do
  describe '#perform_save' do
    context 'saves file' do
      it 'stores in in the aws directory' do
        expect(subject.save(fixture_file_upload('test.json', 'application/json'))).to be_a(String)
      end
    end
  end

  describe '#perform_destroy' do
    context 'development environment' do
      it 'removes the file from aws directory' do
        expect { subject.destroy('12345') }.not_to raise_error
      end
    end
  end
end
