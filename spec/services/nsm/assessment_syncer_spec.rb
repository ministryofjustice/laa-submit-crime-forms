require 'rails_helper'

RSpec.describe Nsm::AssessmentSyncer, :stub_oauth_token do
  describe '.call' do
    let(:claim) do
      create(:claim, :complete, status:)
    end

    let(:status) { 'granted' }

    let(:record) do
      {
        events: [
          {
            event_type: 'decision',
            created_at: 1.day.ago.to_s,
            public: true,
            details: { comment: 'Decision comment' }
          },
        ],
        application: {}
      }.deep_stringify_keys
    end

    let(:arbitrary_fixed_date) { DateTime.new(2024, 2, 1, 15, 23, 27) }

    before do
      travel_to(arbitrary_fixed_date) do
        described_class.call(claim, record:)
      end
    end

    context 'when there is an error' do
      let(:status) { 'rejected' }

      before do
        allow(claim).to receive(:update).and_raise 'Some problem!'
        allow(Sentry).to receive(:capture_message)
        described_class.call(claim, record:)
      end

      it 'notifies Sentry' do
        expect(Sentry).to have_received(:capture_message)
      end
    end

    context 'when status is from a decision event' do
      let(:status) { 'rejected' }

      it 'syncs the assessment_comment' do
        expect(claim.assessment_comment).to eq 'Decision comment'
      end
    end

    context 'when status is from a send_back event' do
      let(:status) { 'provider_requested' }
      let(:record) do
        {
          events: [
            {
              event_type: 'send_back',
              created_at: 1.day.ago.to_s,
              public: true,
              details: { comment: 'More info needed' }
            },
          ],
          application: {}
        }.deep_stringify_keys
      end

      it 'syncs the assessment_comment' do
        expect(claim.assessment_comment).to eq 'More info needed'
      end
    end

    context 'when app has status that should not sync' do
      let(:status) { 'submitted' }

      it 'does not sync any new data' do
        expect(claim.assessment_comment).to be_nil
      end
    end
  end
end
