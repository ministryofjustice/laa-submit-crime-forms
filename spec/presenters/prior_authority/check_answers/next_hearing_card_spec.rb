# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PriorAuthority::CheckAnswers::NextHearingCard do
  subject(:card) { described_class.new(application) }

  describe '#title' do
    let(:application) { build(:prior_authority_application) }

    it 'shows correct title' do
      expect(card.title).to eq('Case and hearing details')
    end
  end

  describe '#row_data' do
    context 'when next hearing date known' do
      let(:application) do
        build(:prior_authority_application,
              next_hearing: true,
              next_hearing_date: 1.month.from_now.to_date)
      end

      it 'generates expected rows' do
        expect(card.row_data).to eq(
          [
            {
              head_key: 'next_hearing_date',
              text: 1.month.from_now.to_date.to_fs(:stamp),
            },
          ]
        )
      end
    end

    context 'when next hearing date NOT known' do
      let(:application) do
        build(:prior_authority_application,
              next_hearing: false,
              next_hearing_date: nil)
      end

      it 'generates expected rows' do
        expect(card.row_data).to eq(
          [
            {
              head_key: 'next_hearing_date',
              text: 'Not known',
            },
          ]
        )
      end
    end
  end
end
