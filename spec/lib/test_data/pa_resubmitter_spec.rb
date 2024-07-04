require 'rails_helper'

RSpec.describe TestData::PaResubmitter do
  describe '#resubmit' do
    let(:client) { double(AppStoreClient, put: true, get: old_payload) }

    let(:old_payload) { SubmitToAppStore::PriorAuthorityPayloadBuilder.new(application:).payload.deep_stringify_keys }

    before do
      allow(AppStoreClient).to receive(:new).and_return(client)
    end

    context 'when there is a further information needed app' do
      let(:application) { create :prior_authority_application, :full, :with_further_information_request }

      it 'can resubmit it' do
        subject.resubmit(100)
        expect(application.reload).to be_provider_updated
        expect(client).to have_received(:put)
      end
    end

    context 'when there is a corrections needed app' do
      let(:application) { create :prior_authority_application, :full, :sent_back_for_incorrect_info }

      it 'can resubmit it' do
        subject.resubmit(100)
        expect(application.reload).to be_provider_updated
        expect(client).to have_received(:put)
      end
    end

    context 'when there is a normal app' do
      let(:application) { create :prior_authority_application, :full, status: :submitted }

      it 'does not touch it' do
        subject.resubmit(100)
        expect(application.reload).to be_submitted
        expect(client).not_to have_received(:put)
      end
    end

    context 'when there is are multiple apps' do
      let(:application) { create :prior_authority_application, :full, :with_further_information_request }
      let(:other_application) { create :prior_authority_application, :full, :with_further_information_request }

      before { other_application }

      it 'respects percentages' do
        subject.resubmit(50)
        expect(client).to have_received(:put).exactly(1).time
        expect(PriorAuthorityApplication.provider_updated.count).to eq 1
      end
    end
  end
end
