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

    context 'when part granted with letters adjusted' do
      let(:status) { 'part_grant' }
      let(:record) do
        {
          application: {
            letters_and_calls: [
              {
                type: {
                  en: 'Letters',
                    value: 'letters'
                },
                count: 30,
                uplift: 0,
                pricing: 3.56,
                uplift_original: 10,
                count_original: 20,
                adjustment_comment: 'Reduced letters and removed uplift'
              },
              {
                type: {
                  en: 'Calls',
                    value: 'calls'
                },
                count: 100,
                uplift: nil,
                pricing: 3.56
              }
            ]
          }
        }.deep_stringify_keys
      end

      it 'syncs letters adjustment fields' do
        expect(claim.allowed_letters).to eq 30
        expect(claim.letters).to eq 20
        expect(claim.letters_uplift).to eq 10
        expect(claim.allowed_letters_uplift).to eq 0
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
