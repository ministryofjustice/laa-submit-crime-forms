require 'rails_helper'

RSpec.describe FileUpload::FileUploader do
  describe '#new' do
    context 'development environment' do
      it 'returns local file uploader' do
        expect(described_class.new.instance_values['uploader']).to be_a(FileUpload::LocalFileUploader)
      end
    end

    context 'production environment' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
      end

      it 'returns aws file uploader' do
        expect(described_class.new.instance_values['uploader']).to be_a(FileUpload::AwsFileUploader)
      end
    end
  end
end