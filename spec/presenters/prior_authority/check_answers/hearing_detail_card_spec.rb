# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PriorAuthority::CheckAnswers::HearingDetailCard do
  subject(:card) { described_class.new(application) }

  describe '#title' do
    let(:application) { build(:prior_authority_application) }

    it 'shows correct title' do
      expect(card.title).to eq('Hearing details')
    end
  end

  describe '#row_data' do
    context 'when magistrates\' court' do
      let(:application) do
        build(:prior_authority_application,
              next_hearing_date: 1.month.from_now.to_date,
              plea: 'mixed',
              court_type: 'magistrates_court',
              youth_court: true)
      end

      it 'generates expected rows' do
        expect(card.row_data).to eq(
          [
            {
              head_key: 'next_hearing_date',
              text: 1.month.from_now.to_date.to_fs(:stamp),
            },
            {
              head_key: 'plea',
              text: 'Mixed plea',
            },
            {
              head_key: 'court_type',
              text: 'Magistrates\' court',
            },
            {
              head_key: 'youth_court',
              text: 'Yes',
            },
          ]
        )
      end
    end

    context 'when central criminal court with psychiatric liason not accessed' do
      let(:application) do
        build(:prior_authority_application,
              next_hearing_date: 1.month.from_now.to_date,
              plea: 'not_guilty',
              court_type: 'central_criminal_court',
              psychiatric_liaison: false,
              psychiatric_liaison_reason_not: 'whatever')
      end

      it 'generates expected rows' do
        expect(card.row_data).to eq(
          [
            {
              head_key: 'next_hearing_date',
              text: 1.month.from_now.to_date.to_fs(:stamp),
            },
            {
              head_key: 'plea',
              text: 'Not guilty',
            },
            {
              head_key: 'court_type',
              text: 'Central Criminal Court',
            },
            {
              head_key: 'psychiatric_liaison',
              text: 'No',
            },
            {
              head_key: 'psychiatric_liaison_reason_not',
              text: 'whatever',
            },
          ]
        )
      end
    end

    context 'when central criminal court with psychiatric liason accessed' do
      let(:application) do
        build(:prior_authority_application,
              next_hearing_date: 1.month.from_now.to_date,
              plea: 'not_guilty',
              court_type: 'central_criminal_court',
              psychiatric_liaison: true)
      end

      it 'generates expected rows' do
        expect(card.row_data).to eq(
          [
            {
              head_key: 'next_hearing_date',
              text: 1.month.from_now.to_date.to_fs(:stamp),
            },
            {
              head_key: 'plea',
              text: 'Not guilty',
            },
            {
              head_key: 'court_type',
              text: 'Central Criminal Court',
            },
            {
              head_key: 'psychiatric_liaison',
              text: 'Yes',
            },
          ]
        )
      end
    end

    context 'when crown court' do
      let(:application) do
        build(:prior_authority_application,
              next_hearing_date: 1.month.from_now.to_date,
              plea: 'unknown',
              court_type: 'crown_court',
              youth_court: true)
      end

      it 'generates expected rows' do
        expect(card.row_data).to eq(
          [
            {
              head_key: 'next_hearing_date',
              text: 1.month.from_now.to_date.to_fs(:stamp),
            },
            {
              head_key: 'plea',
              text: 'Unknown',
            },
            {
              head_key: 'court_type',
              text: 'Crown Court (excluding Central Criminal Court)',
            },
          ]
        )
      end
    end
  end
end
