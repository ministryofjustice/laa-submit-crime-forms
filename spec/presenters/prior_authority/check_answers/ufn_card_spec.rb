# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PriorAuthority::CheckAnswers::UfnCard do
  subject(:card) { described_class.new(application) }

  describe '#title' do
    let(:application) { build(:prior_authority_application) }

    it 'shows correct title' do
      expect(card.title).to eq('Application details')
    end
  end

  describe '#row_data' do
    let(:application) do
      build(:prior_authority_application,
            laa_reference: 'LAA-u2u2u2',
            prison_law: false,
            ufn: '111111/111')
    end

    it 'generates expected rows' do
      expect(card.row_data).to eq(
        [
          {
            head_key: 'prison_law',
            text: 'No'
          },
          {
            head_key: 'laa_reference',
            text: 'LAA-u2u2u2'
          },
          {
            head_key: 'ufn',
            text: '111111/111'
          },
        ]
      )
    end
  end
end
