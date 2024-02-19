require 'rails_helper'

RSpec.describe PriorAuthority::Steps::AlternativeQuotes::DetailForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      record: record,
      application: application,
      contact_full_name: 'John Smith',
      organisation: 'Acme Ltd',
      postcode: 'SW1 1AA',
      file_upload: file_upload,
      items: '1',
      cost_per_item: '1'
    }
  end

  let(:record) { build(:quote, document: nil) }
  let(:application) { build(:prior_authority_application, service_type: 'photocopying') }

  describe '#save' do
    let(:file_upload) { instance_double(ActionDispatch::Http::UploadedFile, tempfile:, content_type:) }
    let(:tempfile) { instance_double(File, size: 150) }
    let(:uploader) { instance_double(FileUpload::FileUploader, scan_file: nil) }
    let(:content_type) { 'application/pdf' }

    before do
      allow(FileUpload::FileUploader).to receive(:new).and_return(uploader)
    end

    context 'when file for upload is invalid' do
      let(:content_type) { 'application/dodgy-executable' }

      it 'returns false' do
        expect(subject.save).to be false
      end

      it 'adds an appropriate error message' do
        subject.save
        expect(subject.errors[:file_upload]).to include(
          'The selected file must be a DOC, DOCX, XLSX, XLS, RTF, ODT, JPG, BMP, PNG, TIF or PDF'
        )
      end
    end

    context 'when file upload fails' do
      before do
        allow(uploader).to receive(:upload).and_raise StandardError
      end

      it 'returns false' do
        expect(subject.save).to be false
      end

      it 'adds an appropriate error message' do
        subject.save
        expect(subject.errors[:file_upload]).to include(
          'Unable to upload file at this time'
        )
      end
    end
  end
end
