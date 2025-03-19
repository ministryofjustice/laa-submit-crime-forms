require 'rails_helper'

RSpec.describe Nsm::ImportForm do
  subject(:form) { described_class.new }

  before do
    # Mock document-related methods from the DocumentUploadable concern
    allow(form).to receive_messages(document_already_uploaded?: false, validate_uploaded_file: true)
  end

  describe 'validations' do
    context 'when file_upload is not present' do
      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:file_upload]).to include(
          I18n.t('activemodel.errors.models.nsm/import_form.attributes.file_upload.blank')
        )
      end
    end

    context 'when file_upload is present' do
      before do
        allow(form).to receive(:file_upload).and_return(
          ActionDispatch::Http::UploadedFile.new(
            tempfile: Tempfile.new('test.xml'),
            filename: 'test.xml',
            type: 'text/xml'
          )
        )
      end

      it 'is valid with respect to file_upload presence' do
        form.valid?
        expect(form.errors[:file_upload]).not_to include(
          I18n.t('activemodel.errors.models.nsm/import_form.attributes.file_upload.blank')
        )
      end
    end
  end
end
