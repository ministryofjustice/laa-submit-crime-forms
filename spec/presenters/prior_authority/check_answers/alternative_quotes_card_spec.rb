# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PriorAuthority::CheckAnswers::AlternativeQuotesCard do
  subject(:card) { described_class.new(application) }

  let(:application) do
    build(
      :prior_authority_application,
      quotes: [quote],
    )
  end

  describe '#title' do
    let(:quote) { build_stubbed(:quote, :alternative, contact_first_name: 'Joe', contact_last_name: 'Bloggs') }

    it 'shows correct title' do
      expect(card.title).to eq('Alternative quotes')
    end
  end

  describe '#row_data' do
    let(:application) do
      create(
        :prior_authority_application,
        quotes:,
      )
    end

    context 'when alternative quotes exist' do
      let(:quotes) do
        [
          build(:quote, :primary),
          build(:quote, :alternative, contact_first_name: 'Jim', contact_last_name: 'Bob',
                cost_per_hour: 20, period: 60, travel_cost_per_hour: 30, travel_time: 60),
          build(:quote, :alternative, contact_first_name: 'John', contact_last_name: 'Boy', document: nil,
                cost_per_hour: 20, period: 120, travel_cost_per_hour: 30, travel_time: 120),
        ]
      end

      it 'generates expected rows' do
        expect(card.row_data).to eq(
          [
            {
              head_key: 'quote_summary',
              head_opts: { count: 1 },
              text: 'Jim Bob<br>test.png<br>£50.00'
            },
            {
              head_key: 'quote_summary',
              head_opts: { count: 2 },
              text: 'John Boy<br>£100.00'
            },
          ]
        )
      end
    end

    context 'when no alternative quotes exist' do
      let(:application) do
        create(
          :prior_authority_application,
          quotes: [],
          no_alternative_quote_reason: 'No other experts available',
        )
      end

      it 'generates expected rows' do
        expect(card.row_data).to eq(
          [
            {
              head_key: 'no_alternatve_quotes',
              text: '<p>No other experts available</p>'
            },
          ]
        )
      end
    end
  end
end
