require 'rails_helper'

RSpec.describe PriorAuthority::Steps::ReasonWhyController, type: :controller do
  before do
    allow(controller).to receive(:current_application).and_return(current_application)
  end

  describe '#create' do
    context 'when a file is uploaded' do
      let(:current_application) { create(:prior_authority_application) }

      before do
        request.env['CONTENT_TYPE'] = 'image/png'
        expect(Clamby).to receive(:safe?).and_return(true)
        post :create, params: { id: '12345', documents: fixture_file_upload('test.png', 'image/png') }
      end

      after do
        FileUtils.rm SupportingDocument.find(response.parsed_body['success']['evidence_id']).file_path
      end

      it 'uploads and returns a success' do
        expect(response).to be_successful
      end

      it 'returns the evidence_id' do
        expect(response.parsed_body['success']['evidence_id']).not_to be_empty
      end
    end

    context 'when a file fails to upload' do
      let(:current_application) { build(:prior_authority_application) }

      before do
        request.env['CONTENT_TYPE'] = 'image/png'
        post :create, params: { id: '12345', documents: nil }
      end

      it 'returns a bad request' do
        expect(response).to be_bad_request
      end

      it 'returns an error message' do
        expect(response.parsed_body['error']['message']).to eq 'Unable to upload file at this time'
      end
    end

    context 'when an incorrect file is uploaded' do
      let(:current_application) { build(:claim) }

      before do
        post :create, params: { id: '12345', documents: fixture_file_upload('test.json', 'application/json') }
      end

      it 'returns a bad request' do
        expect(response).to be_bad_request
      end

      it 'returns an error message' do
        expect(response.parsed_body['error']['message']).to eq 'Incorrect file type provided'
      end
    end

    context 'when an vulnerable file is uploaded' do
      let(:current_application) { build(:prior_authority_application) }

      before do
        request.env['CONTENT_TYPE'] = 'image/png'
        expect(Clamby).to receive(:safe?).and_return(false)
        post :create, params: { id: '12345', documents: fixture_file_upload('test.png', 'image/png') }
      end

      it 'returns a bad request' do
        expect(response).to be_bad_request
      end

      it 'returns an error message' do
        expect(response.parsed_body['error']['message']).to eq('File potentially contains malware so cannot be ' \
                                                               'uploaded. Please contact your administrator')
      end
    end
  end

  describe '#destroy' do
    let(:current_application) { create(:prior_authority_application) }
    let(:evidence) do
      create(:supporting_document,
             file_size: '2857',
             documentable_id: current_application.id,
             file_path: Rails.root.join('spec/fixtures/files/12345').to_s)
    end

    context 'when there are files present' do
      before do
        FileUtils.cp Rails.root.join('spec/fixtures/files/test.png'), Rails.root.join('spec/fixtures/files/12345')
      end

      it 'deletes the file' do
        delete :destroy, params: { id: '12345', evidence_id: evidence.id }

        expect(response).to be_successful
      end
    end

    context 'when there are no files present' do
      it 'returns a 400' do
        delete :destroy, params: { id: '12345', evidence_id: SecureRandom.uuid }

        expect(response).to be_bad_request
      end
    end
  end
end
