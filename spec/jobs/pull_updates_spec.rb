require 'rails_helper'

RSpec.describe PullUpdates do
  let(:last_update) { 2 }
  let(:http_puller) { instance_double(HttpPuller, get_all: http_response) }
  let(:arbitrary_fixed_date) { DateTime.new(2021, 12, 1, 13, 23, 24) }
  let(:http_response) do
    {
      'applications' => [{
        'application_id' => id,
        'version' => 2,
        'application_state' => 'granted',
        'application_risk' => 'high',
        'application_type' => application_type,
        'updated_at' => arbitrary_fixed_date
      }]
    }
  end
  let(:application_type) { 'crm7' }

  before do
    allow(HttpPuller).to receive(:new).and_return(http_puller)
  end

  context 'when mocking claim' do
    let(:id) { SecureRandom.uuid }
    let(:claim) { instance_double(Claim, update!: true) }

    before do
      allow(Claim).to receive_messages(maximum: last_update, find_by: claim)
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
          app_store_updated_at: arbitrary_fixed_date
        )
      end

      context 'when claim does not exist' do
        let(:claim) { nil }

        it 'skips the update' do
          expect { subject.perform }.not_to raise_error
        end
      end
    end
  end

  context 'when claim is not mocked' do
    let(:id) { claim.id }
    let(:claim) { create(:claim) }

    it 'the claim is updated' do
      expect { subject.perform }.not_to raise_error

      expect(claim.reload).to have_attributes(
        status: 'granted'
      )
    end
  end

  context 'when updating a prior authority application' do
    let(:application_type) { 'crm4' }

    context 'when ID is not recognised' do
      let(:id) { 'unknown' }

      it 'does not raise an error' do
        expect { subject.perform }.not_to raise_error
      end
    end

    context 'when ID is recognised' do
      let(:id) { application.id }
      let(:application) { create(:prior_authority_application) }

      it 'processed the update' do
        subject.perform
        expect(application.reload).to have_attributes(
          status: 'granted',
          app_store_updated_at: arbitrary_fixed_date
        )
      end
    end
  end
end
