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
    let(:additional_cost) { build(:additional_cost) }
    let(:status) { 'granted' }

    let(:payload) do
      {
        events: [
          {
            event_type: 'Event::Decision',
            created_at: 1.day.ago,
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
          ]
        }
      }
    end

    let(:app_store_stub) do
      stub_request(:get, "http://localhost:8000/v1/application/#{application.id}").to_return(
        status: 200,
        body: payload.to_json,
        headers: { 'Content-Type' => 'application/json; charset=utf-8' }
      )
    end

    before do
      app_store_stub
      described_class.call(application)
      primary_quote.reload
      additional_cost.reload
    end

    it 'calls the app store' do
      expect(app_store_stub).to have_been_requested
    end

    it 'sets the overall comment' do
      expect(application.assessment_comment).to eq 'Decision comment'
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
        expect(primary_quote.base_adjustment_comment).to eq 'Service cost comment'
        expect(primary_quote.travel_adjustment_comment).to eq 'Travel comment'
      end

      it 'syncs the additional cost adjustment comments' do
        expect(additional_cost.adjustment_comment).to eq 'Additional cost comment'
      end
    end
  end
end
