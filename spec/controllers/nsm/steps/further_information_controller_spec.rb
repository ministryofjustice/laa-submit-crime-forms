require 'rails_helper'

RSpec.describe Nsm::Steps::FurtherInformationController, type: :controller do
  let(:current_application) { create(:claim, :with_further_information_request) }

  describe '#destroy' do
    let(:evidence) do
      create(
        :further_information_document,
        file_size: '2857',
        documentable_id: current_application.further_informations.last.id,
        file_path: Rails.root.join('spec/fixtures/files/12345').to_s
      )
    end

    context 'when there are files present' do
      before do
        FileUtils.cp Rails.root.join('spec/fixtures/files/test.png'), Rails.root.join('spec/fixtures/files/12345')
      end

      it 'deletes the file' do
        delete :destroy, params: { id: current_application.id, evidence_id: evidence.id }

        expect(response).to be_successful
      end
    end

    context 'when there are no files present' do
      it 'returns a 400' do
        delete :destroy, params: { id: current_application.id, evidence_id: SecureRandom.uuid }

        expect(response).to be_bad_request
      end
    end
  end

  it_behaves_like 'a multi file upload controller', application: lambda {
                                                                   create(:claim,
                                                                          :with_further_information_request)
                                                                 }
end
