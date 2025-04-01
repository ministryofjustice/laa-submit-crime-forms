require 'rails_helper'

RSpec.describe Nsm::ImportsController, type: :controller do
  describe '#errors' do
    let(:error_path) { Rails.root.join('spec', 'fixtures', 'files', 'example_import_error') }

    context 'an error file is present' do
      before do
        allow(controller).to receive(:errors_file_path).and_return(error_path)
        get :errors
      end

      it 'generates and downloads error file' do
        expect(response.headers['CONTENT-TYPE']).to eq('application/pdf')
      end
    end

    context 'an error file is not present' do
      before do
        allow(JSON).to receive(:parse).and_raise(StandardError)
        get :errors
      end

      it 'shows the missing file page' do
        expect(response).to be_successful
        expect(response).to render_template('nsm/imports/missing_file')
      end
    end
  end
end
