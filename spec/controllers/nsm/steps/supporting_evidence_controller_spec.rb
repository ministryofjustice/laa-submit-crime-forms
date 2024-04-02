require 'rails_helper'

RSpec.describe Nsm::Steps::SupportingEvidenceController, type: :controller do
  before do
    allow(controller).to receive(:current_application).and_return(current_application)
  end

  describe '#destroy' do
    let(:current_application) { create(:claim) }
    let(:evidence) do
      create(:supporting_evidence,
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

  describe '#downlaod' do
    let(:current_application) { create(:claim) }

    it 'renders with success' do
      get :download, params: { id: current_application }

      expect(response).to be_successful
    end
  end

  it_behaves_like 'a multi file upload controller', application: -> { create(:claim) }
end
