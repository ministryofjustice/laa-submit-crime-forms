require 'rails_helper'

RSpec.describe Nsm::ImportsController, type: :controller do
  let(:provider) { create(:provider) }

  before do
    allow(controller).to receive_messages(current_provider: provider, authenticate_provider!: true)
  end

  describe '#extract_version_from_xml' do
    let(:controller_instance) { described_class.new }

    before do
      allow(controller_instance).to receive(:current_provider).and_return(provider)

      # Set up form_object with XML content
      form_object = instance_double(Nsm::ImportForm)
      file_upload = instance_double(ActionDispatch::Http::UploadedFile)
      tempfile = instance_double(Tempfile)

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

    before do
      allow(controller_instance).to receive(:current_provider).and_return(provider)

      # Set up form_object with XML content
      form_object = instance_double(Nsm::ImportForm)
      file_upload = instance_double(ActionDispatch::Http::UploadedFile)
      tempfile = instance_double(Tempfile)

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

  describe '#validate' do
    let(:controller_instance) { described_class.new }

    before do
      allow(controller_instance).to receive(:current_provider).and_return(provider)

      # Set up form_object with XML content
      form_object = instance_double(Nsm::ImportForm)
      file_upload = instance_double(ActionDispatch::Http::UploadedFile)
      tempfile = instance_double(Tempfile)

      allow(tempfile).to receive(:read).and_return(xml_content)
      allow(file_upload).to receive(:tempfile).and_return(tempfile)
      allow(form_object).to receive(:file_upload).and_return(file_upload)

      controller_instance.instance_variable_set(:@form_object, form_object)
    end

    context 'when version element is missing' do
      let(:xml_content) { '<claim><some_data>test</some_data></claim>' }

      it 'returns error for missing version' do
        errors = controller_instance.send(:validate)
        expect(errors).to include(I18n.t('nsm.imports.errors.missing_version'))
      end
    end

    context 'when version is invalid' do
      let(:xml_content) { '<claim><version>0</version></claim>' }

      it 'returns error for invalid version' do
        errors = controller_instance.send(:validate)
        expect(errors).to include(I18n.t('nsm.imports.errors.invalid_version'))
      end
    end

    context 'when version is unsupported' do
      let(:xml_content) { '<claim><version>999</version></claim>' }

      it 'returns error for unsupported version' do
        errors = controller_instance.send(:validate)
        expect(errors.first).to match(/XML version 999 is not supported/)
      end
    end

    context 'when XML is valid but schema validation fails' do
      let(:xml_content) { '<claim><version>1</version></claim>' }

      before do
        # Instead of mocking the Nokogiri::XML::Schema class, let's mock the validate method response
        allow_any_instance_of(Nokogiri::XML::Schema).to receive(:validate).and_return(
          [
            double('SchemaError1', message: 'Schema error 1'),
            double('SchemaError2', message: 'Schema error 2')
          ]
        )

        # Mock File.exist? to return true for the schema file
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?)
          .with(Rails.root.join('app/services/nsm/importers/xml/v1/crm7_claim.xsd'))
          .and_return(true)
      end

      it 'returns schema validation errors' do
        errors = controller_instance.send(:validate)
        expect(errors.length).to eq(2)
        expect(errors.map(&:message)).to contain_exactly('Schema error 1', 'Schema error 2')
      end
    end
  end

  describe '#errors' do
    let(:provider) { create(:provider, failed_imports:) }
    let(:failed_imports) { [] }

    context 'an error record is present with details' do
      let(:failed_imports) { [FailedImport.new(details: '["XML file contains an invalid version number"]')] }

      before do
        get :errors, params: { error_id: failed_imports.first.id }
      end

      it 'generates and downloads error file' do
        expect(response.headers['CONTENT-TYPE']).to eq('application/pdf')
      end
    end

    context 'an error record is present without details' do
      let(:failed_imports) { [FailedImport.new] }

      before do
        get :errors, params: { error_id: failed_imports.first.id }
      end

      it 'shows the missing file page' do
        expect(response).to be_successful
        expect(response).to render_template('nsm/imports/missing_file')
      end
    end

    context 'an error_id is present but it is not attached to an error record' do
      it 'raises an error' do
        expect { get :errors, params: { error_id: 'garbage' } }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context 'an error_id is not present' do
      it 'raises an error' do
        expect { get :errors }.to raise_error ActionController::ParameterMissing
      end
    end
  end
end
