require 'rails_helper'

RSpec.describe Nsm::AssessmentSyncer, :stub_oauth_token do
  describe '.call' do
    let(:claim) do
      create(:claim, :complete, status:)
    end

    let(:status) { 'granted' }

    let(:events) do
      [
        {
          event_type: 'decision',
          created_at: 1.day.ago.to_s,
          public: true,
          details: { comment: 'Decision comment' }
        },
      ]
    end

    let(:letters_and_calls) do
      [
        {
          type: {
            en: 'Letters',
              value: 'letters'
          },
          count: 1,
          uplift: 0,
        },
        {
          type: {
            en: 'Letters',
              value: 'calls'
          },
          count: 1,
          uplift: 0,
        }
      ]
    end

    let(:application) do
      {
        letters_and_calls: letters_and_calls,
        work_items: [],
        disbursements: []
      }
    end

    let(:record) do
      {
        application:,
        events:
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
        allow(claim).to receive(:status).and_raise 'Some problem!'
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
          application: application,
          events: [
            {
              event_type: 'send_back',
              created_at: 1.day.ago.to_s,
              public: true,
              details: { comment: 'More info needed' }
            },
          ]
        }.deep_stringify_keys
      end

      it 'syncs the assessment_comment' do
        expect(claim.assessment_comment).to eq 'More info needed'
      end
    end

    context 'when part granted with letters and calls adjusted' do
      let(:claim) do
        create(:claim, :complete, :letters_calls_uplift, status:)
      end

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
                count: 1,
                uplift: 0,
                uplift_original: 10,
                count_original: 2,
                adjustment_comment: 'Reduced letters and removed uplift'
              },
              {
                type: {
                  en: 'Calls',
                    value: 'calls'
                },
                count: 2,
                uplift: 0,
                uplift_original: 20,
                count_original: 3,
                adjustment_comment: 'Reduced calls and removed uplift'
              }
            ],
            work_items: []
          },
          events: [
            {
              event_type: 'decision',
              created_at: 1.day.ago.to_s,
              public: true,
              details: { comment: 'Part granted' }
            },
          ],
        }.deep_stringify_keys
      end

      it 'syncs letters adjustment fields' do
        expect(claim.allowed_letters).to eq 1
        expect(claim.letters).to eq 2
        expect(claim.letters_uplift).to eq 10
        expect(claim.allowed_letters_uplift).to eq 0
        expect(claim.letters_adjustment_comment).to eq 'Reduced letters and removed uplift'
      end

      it 'syncs calls adjustment fields' do
        expect(claim.allowed_calls).to eq 2
        expect(claim.calls).to eq 3
        expect(claim.allowed_calls_uplift).to eq 0
        expect(claim.calls_uplift).to eq 20
        expect(claim.calls_adjustment_comment).to eq 'Reduced calls and removed uplift'
      end
    end

    context 'when part granted with work items adjusted' do
      let(:status) { 'part_grant' }
      let(:claim) { create(:claim, :two_uplifted_work_items, status:) }
      let(:adjusted_work_item) { claim.work_items[0] }
      let(:work_item) { claim.work_items[1] }
      let(:record) do
        {
          application: {
            letters_and_calls: letters_and_calls,
            work_items: [
              {
                id: adjusted_work_item.id,
                uplift: 0,
                time_spent: 20,
                uplift_original: 15,
                adjustment_comment: 'Test comment 1',
                time_spent_original: 40
              },
              {
                id: work_item.id,
                uplift: 0,
                time_spent: 120
              }
            ]
          },
          events: [
            {
              event_type: 'decision',
              created_at: 1.day.ago.to_s,
              public: true,
              details: { comment: 'Part granted' }
            },
          ],
        }.deep_stringify_keys
      end

      it 'syncs adjusted work item' do
        expect(adjusted_work_item.allowed_uplift).to eq 0
        expect(adjusted_work_item.adjustment_comment).to eq 'Test comment 1'
        expect(adjusted_work_item.allowed_time_spent).to eq 20
      end

      it 'does not sync non adjusted work item' do
        expect(work_item.allowed_time_spent).to be_nil
        expect(work_item.allowed_uplift).to be_nil
        expect(work_item.adjustment_comment).to be_nil
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
