require 'rails_helper'

RSpec.describe Nsm::Steps::FurtherInformationController, type: :controller do
  before do
    allow(AppStoreClient).to receive(:new).and_return(dummy_client)
    allow(dummy_client).to receive(:get).and_return(app_store_record)
  end

  let(:current_application) { create(:claim, :complete, :case_type_magistrates, :with_further_information_request) }
  let(:dummy_client) { instance_double(AppStoreClient) }
  let(:app_store_record) do
    {
      application_id: current_application.id,
      application_state: 'sent_back',
      application: application_payload,
    }.deep_stringify_keys
  end
  let(:application_payload) do
    SubmitToAppStore::NsmPayloadBuilder.new(claim: current_application).send(:construct_payload).merge(
      further_information: [
        current_application.further_informations.first.as_json
      ]
    )
  end

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
end
