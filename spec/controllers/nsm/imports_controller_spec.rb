require 'rails_helper'

RSpec.describe Nsm::ImportsController, :stub_oauth_token, type: :controller do
  let(:provider) { create(:provider) }

  before do
    allow(controller).to receive_messages(current_provider: provider, authenticate_provider!: true)
  end

  describe '#create' do
    let(:controller_instance) { described_class.new }

    before do
      allow(controller_instance).to receive(:current_provider).and_return(provider)
    end

    context 'there is a validation error in the xml file' do
      let(:validation_errors) { ['XML file contains an invalid version number'] }
      let(:error_id) { SecureRandom.uuid }
      let(:params) { { nsm_import_form: { file_upload: ActionDispatch::Http::UploadedFile } } }

      before do
        allow_any_instance_of(Nsm::ImportForm).to receive(:valid?).and_return(true)
        allow_any_instance_of(Nsm::ImportForm).to receive(:validate_xml_file).and_return(validation_errors)
        allow_any_instance_of(AppStoreClient).to receive(:post_import_error).and_return({ 'id' => error_id })
      end

      it 're-renders page with error' do
        post(:create, params:)
        expect(response).to render_template(:new)
      end
    end
  end

  describe '#extract_version_from_xml' do
    let(:controller_instance) { described_class.new }
    let(:file_upload) { instance_double(ActionDispatch::Http::UploadedFile) }
    let(:form_object) { instance_double(Nsm::ImportForm, file_upload: file_upload, xml_file: parsed_xml) }
    let(:tempfile) { instance_double(Tempfile) }
    let(:xml_content) { nil }
    let(:parsed_xml) { Nokogiri::XML::Document.parse(xml_content, &:noblanks) }

    before do
      allow(controller_instance).to receive(:current_provider).and_return(provider)
      allow(tempfile).to receive(:read).and_return(xml_content)
      allow(file_upload).to receive(:tempfile).and_return(tempfile)
      allow(form_object).to receive(:file_upload).and_return(file_upload)

      controller_instance.instance_variable_set(:@form_object, form_object)
    end

    context 'when version is missing' do
      let(:xml_content) { '<claim></claim>' }

      it 'raises an error' do
        expect { controller_instance.send(:extract_version_from_xml) }
          .to raise_error(StandardError, /missing version/i)
      end
    end

    context 'when version is invalid (not positive)' do
      let(:xml_content) { '<claim><version>0</version></claim>' }

      it 'raises an error' do
        expect { controller_instance.send(:extract_version_from_xml) }
          .to raise_error(StandardError, /missing version/i)
      end
    end

    context 'when version is valid' do
      let(:xml_content) { '<claim><version>1</version></claim>' }

      it 'returns the version number' do
        expect(controller_instance.send(:extract_version_from_xml)).to eq(1)
      end
    end
  end

  describe '#claim_hash' do
    let(:controller_instance) { described_class.new }
    let(:form_object) { instance_double(Nsm::ImportForm, file_upload: file_upload, xml_file: parsed_xml) }
    let(:file_upload) { instance_double(ActionDispatch::Http::UploadedFile) }
    let(:tempfile) { instance_double(Tempfile) }
    let(:xml_content) { nil }
    let(:parsed_xml) { Nokogiri::XML::Document.parse(xml_content, &:noblanks) }

    before do
      allow(controller_instance).to receive(:current_provider).and_return(provider)
      allow(tempfile).to receive(:read).and_return(xml_content)
      allow(file_upload).to receive(:tempfile).and_return(tempfile)
      allow(form_object).to receive(:file_upload).and_return(file_upload)

      controller_instance.instance_variable_set(:@form_object, form_object)
    end

    context 'when XML has version and other attributes' do
      let(:xml_content) do
        <<~XML
          <claim id="123" status="draft">
            <version>1</version>
            <defendant_name>John Doe</defendant_name>
            <maat_reference>12345</maat_reference>
          </claim>
        XML
      end

      it 'returns hash with version removed' do
        result = controller_instance.send(:claim_hash)

        # Version should be removed
        expect(result).not_to include('version')

        # Other attributes should be present
        expect(result).to include('defendant_name')
        expect(result['defendant_name']).to eq('John Doe')
        expect(result).to include('maat_reference')
        expect(result['maat_reference']).to eq('12345')

        # The root attributes should not be present
        expect(result).not_to include('id')
        expect(result).not_to include('status')
      end
    end
  end

  describe '#errors' do
    let(:dummy_client) { instance_double(AppStoreClient) }
    let(:failed_import_payload) do
      {
        'id' => fail_id,
        'provider_id' => provider.id,
        'details' => details
      }
    end
    let(:fail_id) { SecureRandom.uuid }
    let(:details) { '["XML file contains an invalid version number"]' }

    before do
      allow(AppStoreClient).to receive(:new).and_return(dummy_client)
      allow(dummy_client).to receive(:get_import_error).and_return(failed_import_payload)
    end

    context 'an error record is present with details' do
      before do
        get :errors, params: { error_id: fail_id }
      end

      it 'generates and downloads error file' do
        expect(response.headers['CONTENT-TYPE']).to eq('application/pdf')
      end
    end

    context 'an error record is present without details' do
      let(:details) { nil }

      before do
        get :errors, params: { error_id: fail_id }
      end

      it 'shows the missing file page' do
        expect(response).to be_successful
        expect(response).to render_template('nsm/imports/missing_file')
      end
    end

    context 'an error_id is present but it is not attached to an error record' do
      before do
        allow(dummy_client).to receive(:get_import_error).and_raise(RuntimeError)
      end

      it 'raises an error' do
        expect { get :errors, params: { error_id: fail_id } }.to raise_error RuntimeError
      end
    end

    context 'an error_id is not present' do
      it 'raises an error' do
        expect { get :errors }.to raise_error ActionController::ParameterMissing
      end
    end
  end
end
