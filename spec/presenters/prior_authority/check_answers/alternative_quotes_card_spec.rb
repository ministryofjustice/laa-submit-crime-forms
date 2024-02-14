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
    let(:quote) { build_stubbed(:quote, :alternative, contact_full_name: 'Joe Bloggs') }

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
          build(:quote, :alternative, contact_full_name: 'Jim Bob',
                cost_per_hour: 20, period: 60, travel_cost_per_hour: 30, travel_time: 60),
          build(:quote, :alternative, contact_full_name: 'John Boy',
                cost_per_hour: 20, period: 120, travel_cost_per_hour: 30, travel_time: 120),
        ]
      end

      it 'generates expected rows' do
        expect(card.row_data).to eq(
          [
            {
              head_key: 'quote_summary',
              text: 'Jim Bob<br>£50.00'
            },
            {
              head_key: 'quote_summary',
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
              text: 'No other experts available'
            },
          ]
        )
      end
    end
  end
end
