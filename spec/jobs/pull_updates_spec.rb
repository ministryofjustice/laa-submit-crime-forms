require 'rails_helper'

RSpec.describe PullUpdates do
  let(:id) { SecureRandom.uuid }
  let(:last_update) { Date.new(2021,11,30) }
  let(:http_puller) { instance_double(AppStoreClient) }
  let(:arbitrary_fixed_date) { '2021-12-01T23:24:58.846345' }
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
    allow(AppStoreClient).to receive(:new).and_return(http_puller)
    allow(http_puller).to receive(:get_all).and_return('applications' => [])
    allow(http_puller).to receive(:get_all).with(since: PullUpdates::EARLIEST_POLL_DATE, count: 100)
                                           .and_return(http_response)
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
          app_store_updated_at: Time.zone.parse(arbitrary_fixed_date)
        )
      end

      context 'when claim does not exist' do
        let(:claim) { nil }

        it 'skips the update' do
          expect { subject.perform }.not_to raise_error
        end
      end
    end

    context 'ensure loop ends' do
      before do
        allow(http_puller).to receive(:get_all).with(since: Time.zone.parse(arbitrary_fixed_date), count: 100)
                                               .and_return(http_response)
      end

      it 'does not get stuck due to non-integer timetamps' do
        expect { Timeout.timeout(1) { subject.perform } }.not_to raise_error
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

    before do
      allow(PriorAuthority::AssessmentSyncer).to receive(:call)
    end

    context 'when ID is not recognised' do
      let(:id) { 'unknown' }

      it 'does not raise an error' do
        expect { subject.perform }.not_to raise_error
      end
    end

    context 'when ID is recognised' do
      let(:id) { application.id }
      let(:application) { create(:prior_authority_application) }

      it 'processes the update' do
        subject.perform
        expect(application.reload).to have_attributes(
          status: 'granted',
          app_store_updated_at: Time.zone.parse(arbitrary_fixed_date)
        )
      end

      it 'triggers a sync' do
        subject.perform
        expect(PriorAuthority::AssessmentSyncer).to have_received(:call).with(application)
      end
    end

    context 'with multiple updates' do
      let(:paa_one) { create(:prior_authority_application, :full, status: 'submitted') }
      let(:paa_two) { create(:prior_authority_application, :full, status: 'submitted') }

      let(:http_response) do
        {
          'applications' =>
            [
              {
                'application_id' => paa_one.id,
                'version' => 2,
                'application_state' => 'granted',
                'application_risk' => 'N/A',
                'application_type' => application_type,
                'updated_at' => arbitrary_fixed_date
              },
              {
                'application_id' => paa_two.id,
                'version' => 2,
                'application_state' => 'rejected',
                'application_risk' => 'N/A',
                'application_type' => application_type,
                'updated_at' => arbitrary_fixed_date
              },
            ]
        }
      end

      let(:get_response_one) do
        {
          'application_state' => 'granted',
          'application_type' => 'crm4',
          'events' => [
            {
              'details' => { 'comment' => 'All good, granting...' },
              'created_at' => '2024-03-26T16:56:27.039Z',
              'public' => true,
              'event_type' => 'decision'
            }
          ],
        }
      end

      let(:get_response_two) do
        {
          'application_state' => 'rejected',
          'application_type' => 'crm4',
          'events' => [
            {
              'details' => { 'comment' => 'Sorry have to reject this because...' },
              'created_at' => '2024-03-26T16:56:27.039Z',
              'public' => true,
              'event_type' => 'decision'
            }
          ],
        }
      end

      it 'updates both application statuses' do
        expect { subject.perform }
          .to change { paa_one.reload.status }.from('submitted').to('granted')
          .and change { paa_two.reload.status }.from('submitted').to('rejected')
      end

      context 'when syncing successufully' do
        before do
          allow(PriorAuthority::AssessmentSyncer).to receive(:call).and_call_original

          allow(http_puller).to receive(:get).with(paa_one.id).and_return(get_response_one)
          allow(http_puller).to receive(:get).with(paa_two.id).and_return(get_response_two)
        end

        it 'syncs both applications' do
          expect { subject.perform }
            .to change { paa_one.reload.assessment_comment }.from(nil).to('All good, granting...')
            .and change { paa_two.reload.assessment_comment }.from(nil).to('Sorry have to reject this because...')
        end
      end

      context 'when syncing raises error' do
        before do
          allow(PriorAuthority::AssessmentSyncer).to receive(:call).and_call_original

          allow(http_puller).to receive(:get_all).and_return(http_response)
          allow(http_puller).to receive(:get).with(paa_one.id).and_return(private_response_one)
          allow(http_puller).to receive(:get).with(paa_two.id).and_return(get_response_two)

          allow(Sentry).to receive(:capture_exception)
        end

        let(:private_response_one) do
          {
            'application_state' => 'granted',
            'application_type' => 'crm4',
            'events' => [
              {
                'details' => { 'comment' => 'All good, granting...' },
                'created_at' => '2024-03-26T16:56:27.039Z',
                'public' => false, # <-- this fake change will break the sync, but future changes to payloads could too
                'event_type' => 'decision'
              }
            ],
          }
        end

        it 'syncs (does not block) the unbroken application' do
          subject.perform
          expect(paa_one.reload.assessment_comment).to be_nil
          expect(paa_two.reload.assessment_comment).to eq('Sorry have to reject this because...')
        end

        it 'captures the error' do
          subject.perform
          expect(Sentry)
            .to have_received(:capture_exception)
            .with("PriorAuthority::AssessmentSyncer encountered error 'undefined method `dig' for nil' " \
                  "for application '#{paa_one.id}'")
            .at_least(:once)
        end
      end
    end
  end

  context 'when application type is not recognised' do
    let(:application_type) { 'crm5' }
    let(:id) { 'unknown-id' }

    it 'does not raise an error' do
      expect { subject.perform }.not_to raise_error
    end
  end
end
