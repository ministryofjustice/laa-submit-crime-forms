# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PriorAuthority::CheckAnswers::ClientDetailCard do
  subject(:card) { described_class.new(application) }

  describe '#title' do
    let(:application) { build(:prior_authority_application) }

    it 'shows correct title' do
      expect(card.title).to eq('Client details')
    end
  end

  describe '#row_data' do
    let(:application) do
      build(:prior_authority_application, defendant:)
    end

    let(:defendant) { build(:defendant, first_name: 'Jim', last_name: 'Bob', date_of_birth: Date.parse('2001-01-01')) }

    it 'generates expected rows' do
      expect(card.row_data).to eq(
        [
          {
            head_key: 'full_name',
            text: 'Jim Bob'
          },
          {
            head_key: 'date_of_birth',
            text: '01 January 2001'
          },
        ]
      )
    end
  end
end
