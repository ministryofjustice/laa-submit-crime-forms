require 'rails_helper'

RSpec.describe PullUpdates do
  let(:last_update) { 2 }
  let(:http_puller) { instance_double(HttpPuller, get_all: http_response) }
  let(:http_response) do
    {
      'applications' => [{
        'application_id' => id,
        'version' => 2,
        'application_state' => 'granted',
        'application_risk' => 'high',
        'updated_at' => 10
      }]
    }
  end
  let(:id) { SecureRandom.uuid }
  let(:claim) { instance_double(Claim, update!: true) }

  before do
    allow(Claim).to receive_messages(maximum: last_update, find_by: claim)
    allow(HttpPuller).to receive(:new).and_return(http_puller)
  end

  context 'no data since last pull' do
    let(:http_response) { { 'applications' => [] } }

    it 'do nothing' do
      subject.perform
      expect(Claim).not_to have_received(:find_by)
    end
  end

  context 'when data exists' do
    it 'updates the claim' do
      subject.perform

      expect(Claim).to have_received(:find_by).with(id:)
      expect(claim).to have_received(:update!).with(
        status: 'granted',
        app_store_updated_at: 10
      )
    end

    context 'when claim does not exist' do
      let(:claim) { nil }

      it 'skips the update' do
        expect { subject.perform }.not_to raise_error
      end
    end
  end

  context 'when it is not mocked' do
    let(:id) { claim.id }
    let(:claim) { create(:claim) }

    it 'the claim is updated' do
      expect { subject.perform }.not_to raise_error

      expect(claim.reload).to have_attributes(
        status: 'granted'
      )
    end
  end
end
