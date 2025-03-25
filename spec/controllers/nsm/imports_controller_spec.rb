require 'rails_helper'

RSpec.describe Nsm::ImportsController, type: :controller do
  let(:provider) { create(:provider) }

  before do
    allow(controller).to receive_messages(current_provider: provider, authenticate_provider!: true)
  end

  describe '#create' do
    context 'when handling errors' do
      let(:file) { fixture_file_upload('spec/fixtures/files/import_sample.xml', 'text/xml') }

      it 'handles standard errors properly' do
        # Simulate a StandardError during processing
        allow_any_instance_of(described_class).to receive(:extract_version_from_xml)
          .and_raise(StandardError, 'Test error')

        # Skip validation to avoid file scanning issues
        allow_any_instance_of(Nsm::ImportForm).to receive(:valid?).and_return(true)

        post :create, params: { nsm_import_form: { file_upload: file } }

        # Check if the form has errors, without looking at specific message
        expect(assigns(:form_object).errors[:file_upload]).not_to be_empty
        expect(response).to render_template(:new)
      end

      it 'handles missing parameter errors' do
        allow(controller).to receive(:params).and_raise(ActionController::ParameterMissing.new('param'))
        post :create

        expect(response).to render_template(:new)
      end
    end
  end

  describe '#extract_version_from_xml' do
    let(:controller_instance) { described_class.new }

    before do
      # Set up the controller with the same provider
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
  end
end
