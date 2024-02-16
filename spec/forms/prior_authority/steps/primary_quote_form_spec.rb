require 'rails_helper'

RSpec.describe PriorAuthority::Steps::PrimaryQuoteForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      record:,
      application:,
      service_type:,
      custom_service_name:,
      contact_full_name:,
      organisation:,
      postcode:,
      file_upload:,
    }
  end

  let(:record) { instance_double(Quote, document:) }
  let(:document) { instance_double(SupportingDocument, file_name: 'foo.png') }
  let(:application) { instance_double(PriorAuthorityApplication, service_type: 'forensics') }
  let(:file_upload) { nil }
  let(:service_type) { 'forensics_expert' }
  let(:custom_service_name) { '' }
  let(:contact_full_name) { 'Joe Bloggs' }
  let(:organisation) { 'LAA' }
  let(:postcode) { 'CR0 1RE' }

  describe '#validate' do
    context 'with valid quote details not including a file upload' do
      it { is_expected.to be_valid }
    end

    context 'when no file has previously been uploaded' do
      let(:document) { instance_double(SupportingDocument, file_name: nil) }

      it 'treats a blank file upload as a validation error' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:file_upload, :blank)).to be(true)
      end
    end

    context 'with blank quote details' do
      let(:service_type) { '' }
      let(:contact_full_name) { '' }
      let(:organisation) { '' }
      let(:postcode) { '' }

      it 'has a validation errors on blank fields' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:service_type, :blank)).to be(true)
        expect(form.errors.of_kind?(:contact_full_name, :blank)).to be(true)
        expect(form.errors.of_kind?(:organisation, :blank)).to be(true)
        expect(form.errors.of_kind?(:postcode, :blank)).to be(true)
        expect(form.errors.messages.values.flatten)
          .to include('Enter the service required',
                      "Enter the contact's full name",
                      'Enter the organisation name',
                      'Enter the postcode')
      end
    end

    context 'with invalid quote details' do
      let(:service_type) { 'Forensics Expert' }
      let(:contact_full_name) { 'Tim' }
      let(:organisation) { 'LAA' }
      let(:postcode) { 'loren ipsum' }

      it 'has a validation errors on blank fields' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:contact_full_name, :invalid)).to be(true)
        expect(form.errors.of_kind?(:postcode, :invalid)).to be(true)
        expect(form.errors.messages.values.flatten)
          .to include('Enter a valid full name',
                      'Enter a real postcode')
      end
    end

    context 'with a file upload' do
      let(:file_upload) { instance_double(ActionDispatch::Http::UploadedFile, tempfile:, content_type:) }
      let(:tempfile) { instance_double(File, size:) }
      let(:size) { 150 }
      let(:content_type) { 'application/msword' }
      let(:uploader) { instance_double(FileUpload::FileUploader, scan_file: nil) }

      before do
        allow(FileUpload::FileUploader).to receive(:new).and_return(uploader)
      end

      context 'with a valid upload' do
        it { is_expected.to be_valid }
      end

      context 'with an overly large file' do
        let(:size) { ENV['MAX_UPLOAD_SIZE_BYTES'].to_i + 1 }

        it 'adds an appropriate error message' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(:file_upload, 'The selected file must be smaller than 1MB')).to be(true)
        end
      end

      context 'with an unsupported file type' do
        let(:content_type) { 'application/dodgy_executable' }

        it 'adds an appropriate error message' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(:file_upload, :forbidden_document_type)).to be(true)
        end
      end

      context 'with suspected malware' do
        before do
          allow(uploader).to receive(:scan_file).and_raise FileUpload::FileUploader::PotentialMalwareError
        end

        it 'adds an appropriate error message' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(:file_upload, :suspected_malware)).to be(true)
        end
      end
    end
  end

  describe '#save' do
    subject(:save) { form.save }

    let(:record) { create(:quote, :blank, prior_authority_application: application) }
    let(:application) { create(:prior_authority_application) }

    context 'with valid quote details' do
      let(:service_type) { 'Forensics Expert' }
      let(:contact_full_name) { 'Joe Bloggs' }
      let(:organisation) { 'LAA' }
      let(:postcode) { 'CR0 1RE' }

      it 'persists the quote' do
        expect { save }.to change { record.reload.attributes }
          .from(
            hash_including(
              'contact_full_name' => nil,
              'organisation' => nil,
              'postcode' => nil,
              'primary' => nil
            )
          )
          .to(
            hash_including(
              'contact_full_name' => 'Joe Bloggs',
              'organisation' => 'LAA',
              'postcode' => 'CR0 1RE',
              'primary' => true
            )
          )
      end

      it 'persists the application changes' do
        expect { save }.to change { application.reload.attributes }
          .from(
            hash_including(
              'service_type' => nil,
            )
          )
          .to(
            hash_including(
              'service_type' => 'Forensics Expert',
              'custom_service_name' => '',
            )
          )
      end
    end

    context 'with incomplete quote details' do
      let(:service_type) { 'Forensics Expert' }
      let(:contact_full_name) { '' }
      let(:organisation) { '' }
      let(:postcode) { '' }

      it 'does not persist the client details' do
        expect { save }.not_to change { record.reload.attributes }
          .from(
            hash_including(
              'contact_full_name' => nil,
              'organisation' => nil,
              'postcode' => nil,
              'primary' => nil
            )
          )
      end
    end

    context 'with a valid file' do
      let(:file_upload) do
        instance_double(ActionDispatch::Http::UploadedFile,
                        tempfile: tempfile,
                        content_type: 'application/msword',
                        original_filename: 'foo.png')
      end
      let(:tempfile) { instance_double(File, size: 150, path: '/tmp/foo.com') }
      let(:uploader) { instance_double(FileUpload::FileUploader, scan_file: nil) }

      before do
        allow(FileUpload::FileUploader).to receive(:new).and_return(uploader)
        allow(uploader).to receive(:upload).and_return('/cloud/url')
      end

      it 'uploads the file' do
        expect(uploader).to receive(:upload).with(file_upload)
        save
      end

      it 'updates the metadata' do
        save
        expect(record.document).to have_attributes(
          file_name: 'foo.png',
          file_type: 'application/msword',
          file_size: 150,
          file_path: '/cloud/url'
        )
      end
    end
  end

  describe '#service_type' do
    subject(:form) { described_class.new(arguments.merge(service_type_suggestion:)) }

    let(:service_type) { 'culture_expert' }

    context 'service type suggestion matches provided service' do
      let(:service_type_suggestion) { 'Culture expert' }

      it { expect(subject.service_type).to eq(PriorAuthority::QuoteServices::CULTURE_EXPERT) }
    end

    context 'service type suggestion matches a different service' do
      let(:service_type_suggestion) { 'Computer expert' }

      it 'uses the service type associated with the suggestion' do
        expect(subject.service_type).to eq(PriorAuthority::QuoteServices::COMPUTER_EXPERT)
      end
    end

    context 'service type suggestion does not match a quote service' do
      let(:service_type_suggestion) { 'garbage value' }

      it { expect(subject.service_type).to eq(PriorAuthority::QuoteServices.new('custom')) }
    end
  end

  describe '#custom_service_name' do
    subject(:form) { described_class.new(arguments.merge(service_type_suggestion:).with_indifferent_access) }

    let(:service_type) { PriorAuthority::QuoteServices.values.sample }

    context 'service type suggestion matches a quote service' do
      let(:service_type_suggestion) { service_type.translated }

      it { expect(subject.custom_service_name).to be_nil }
    end

    context 'service type suggestion does not match a quote service' do
      let(:service_type_suggestion) { 'garbage value' }

      it { expect(subject.custom_service_name).to eq('garbage value') }
    end

    context 'when it is included but blank' do
      let(:service_type_suggestion) { '' }

      it { is_expected.not_to be_valid }
    end
  end
end
