require 'rails_helper'

RSpec.describe PriorAuthority::AssessmentSyncer, :stub_oauth_token do
  describe '.call' do
    let(:application) do
      create(:prior_authority_application, :full,
             status: status,
             quotes: [primary_quote],
             additional_costs: [additional_cost])
    end

    let(:primary_quote) { build(:quote, :primary) }
    let(:additional_cost) { build(:additional_cost, :per_item) }
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
        application: {
          quotes: [
            {
              id: primary_quote.id,
              cost_type: 'per_hour',
              travel_time: 180,
              travel_cost_per_hour: 10.0,
              primary: true,
              cost_per_hour: 20.0,
              cost_per_item: nil,
              items: nil,
              period: 180,
              adjustment_comment: 'Service cost comment',
              travel_adjustment_comment: 'Travel comment'
            }
          ],
          additional_costs: [
            {
              id: additional_cost.id,
              unit_type: 'per_item',
              cost_per_hour: nil,
              cost_per_item: 12.0,
              period: nil,
              items: 10,
              adjustment_comment: 'Additional cost comment'
            }
          ],
          further_information: [
            {
              caseworker_id: 'case-worker-uuid',
              information_requested: 'Need more evidence',
              requested_at: DateTime.current
            }
          ],
          incorrect_information_explanation: 'This is incorrect',
          updates_needed: %w[further_information incorrect_information],
          resubmission_deadline: 14.days.from_now,
        }
      }.deep_stringify_keys
    end

    let(:arbitrary_fixed_date) { DateTime.new(2024, 2, 1, 15, 23, 27) }

    before do
      travel_to(arbitrary_fixed_date) do
        described_class.call(application, record:)
        primary_quote.reload
        additional_cost.reload
      end
    end

    it 'sets the overall comment' do
      expect(application.assessment_comment).to eq 'Decision comment'
    end

    context 'when app is granted' do
      let(:status) { 'granted' }

      it 'syncs the assessment comment' do
        expect(application.assessment_comment).to eq 'Decision comment'
      end
    end

    context 'when app is rejected' do
      let(:status) { 'rejected' }

      it 'syncs the assessment comment' do
        expect(application.assessment_comment).to eq 'Decision comment'
      end
    end

    context 'when the app is part granted' do
      let(:status) { 'part_grant' }

      it 'syncs the primary quote' do
        expect(primary_quote.base_cost_allowed).to eq 60
        expect(primary_quote.travel_cost_allowed).to eq 30
      end

      it 'syncs the additional costs' do
        expect(additional_cost.total_cost_allowed).to eq 120
      end

      it 'syncs the primary quote adjustment comments' do
        expect(primary_quote.service_adjustment_comment).to eq 'Service cost comment'
        expect(primary_quote.travel_adjustment_comment).to eq 'Travel comment'
      end

      it 'syncs the additional cost adjustment comments' do
        expect(additional_cost.adjustment_comment).to eq 'Additional cost comment'
      end

      context 'when there is an error' do
        before do
          allow(PriorAuthority::Steps::ServiceCostForm).to receive(:new).and_raise 'Some problem!'
          allow(Sentry).to receive(:capture_message)
          described_class.call(application, record:)
        end

        it 'notifies Sentry' do
          expect(Sentry).to have_received(:capture_message)
        end
      end
    end

    context 'when app is sent back' do
      let(:status) { 'sent_back' }

      context 'with further info and incorrect info' do
        it 'syncs the incorrect info' do
          expect(application.incorrect_information_explanation).to eq 'This is incorrect'
        end

        it 'syncs dates' do
          expect(application.resubmission_deadline).to eq arbitrary_fixed_date + 14.days
          expect(application.resubmission_requested).to eq arbitrary_fixed_date
        end
      end

      context 'with only further info' do
        let(:record) do
          {
            application: {
              updates_needed: ['further_information'],
              further_information: [
                {
                  caseworker_id: 'case-worker-uuid',
                  information_requested: 'Need more evidence',
                  requested_at: DateTime.current
                }
              ],
            }
          }.deep_stringify_keys
        end

        it 'nullifies the incorrect info' do
          expect(application.incorrect_information_explanation).to be_nil
        end

        it 'syncs the further info' do
          expect(application.further_informations.exists?).to be true
        end
      end

      context 'with only incorrect info' do
        let(:record) do
          {
            application: {
              incorrect_information_explanation: 'This is incorrect',
              updates_needed: ['incorrect_information']
            }
          }.deep_stringify_keys
        end

        it 'syncs the incorrect info' do
          expect(application.incorrect_information_explanation).to eq 'This is incorrect'
        end
      end
    end

    context 'when app has status that should not sync' do
      let(:status) { nil }

      it 'does not sync any new data' do
        expect(application.assessment_comment).to be_nil
      end
    end
  end
end
