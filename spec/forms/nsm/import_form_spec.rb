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

    context 'when file upload has unreadable file' do
      before do
        allow(form).to receive(:file_upload).and_return(
          ActionDispatch::Http::UploadedFile.new(
            tempfile: file_fixture('unreadable_import.xml'),
            filename: 'test.xml',
            type: 'text/xml'
          )
        )
      end

      it 'shows the correct error' do
        expect(JSON.parse(form.validate_xml_file.to_json)).to include(
          "2:0: ERROR: Element 'claim': Missing child element(s). " \
          'Expected is one of ( agent_instructed, arrest_warrant_date, assigned_counsel, ' \
          'calls, calls_uplift, claim_type, cntp_date, cntp_order, concluded, conclusion ).'
        )
      end
    end

    context 'when file upload has unmatched fields' do
      before do
        allow(form).to receive(:file_upload).and_return(
          ActionDispatch::Http::UploadedFile.new(
            tempfile: file_fixture('unmatched_fields.xml'),
            filename: 'test.xml',
            type: 'text/xml'
          )
        )
      end

      it 'shows the correct error' do
        expect(JSON.parse(form.validate_xml_file.to_json)).to include(
          "2:0: ERROR: Element 'claim': Missing child element(s). " \
          'Expected is one of ( agent_instructed, arrest_warrant_date, assigned_counsel, ' \
          'calls, calls_uplift, claim_type, cntp_date, cntp_order, concluded, conclusion ).'
        )
      end
    end

    context 'when file upload has unsupported versions' do
      before do
        allow(form).to receive(:file_upload).and_return(
          ActionDispatch::Http::UploadedFile.new(
            tempfile: file_fixture('import_sample_incorrect_version.xml'),
            filename: 'test.xml',
            type: 'text/xml'
          )
        )
      end

      it 'shows the correct error' do
        expect(JSON.parse(form.validate_xml_file.to_json)).to eq(['XML version 2 is not supported'])
      end
    end

    context 'when file upload has a missing version element' do
      before do
        allow(form).to receive(:file_upload).and_return(
          ActionDispatch::Http::UploadedFile.new(
            tempfile: file_fixture('import_sample_without_version.xml'),
            filename: 'test.xml',
            type: 'text/xml'
          )
        )
      end

      it 'shows the correct error' do
        expect(JSON.parse(form.validate_xml_file.to_json)).to eq([I18n.t('nsm.imports.errors.missing_version')])
      end
    end

    context 'when file upload has invalid version number' do
      before do
        allow(form).to receive(:file_upload).and_return(
          ActionDispatch::Http::UploadedFile.new(
            tempfile: file_fixture('import_sample_invalid_version.xml'),
            filename: 'test.xml',
            type: 'text/xml'
          )
        )
      end

      it 'shows the correct error' do
        expect(JSON.parse(form.validate_xml_file.to_json)).to eq([I18n.t('nsm.imports.errors.invalid_version')])
      end
    end
  end
end
