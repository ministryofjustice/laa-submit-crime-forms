# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PriorAuthority::CheckAnswers::CaseDetailCard do
  subject(:card) { described_class.new(application) }

  describe '#title' do
    let(:application) { build(:prior_authority_application) }

    it 'shows correct title' do
      expect(card.title).to eq('Case details')
    end
  end

  describe '#row_data' do
    let(:defendant) { build(:defendant, maat: '654321') }

    context 'when not client detained' do
      let(:application) do
        build(:prior_authority_application,
              main_offence: 'Supply a controlled drug of Class A - Heroin',
              rep_order_date: 1.month.ago.to_date,
              client_detained: false,
              subject_to_poca: true,
              defendant: defendant)
      end

      it 'generates expected rows' do
        expect(card.row_data).to eq(
          [
            {
              head_key: 'main_offence',
              text: 'Supply a controlled drug of Class A - Heroin',
            },
            {
              head_key: 'rep_order_date',
              text: 1.month.ago.to_date.to_fs(:stamp),
            },
            {
              head_key: 'maat',
              text: '654321',
            },
            {
              head_key: 'client_detained',
              text: 'No',
            },
            {
              head_key: 'subject_to_poca',
              text: 'Yes',
            },
          ]
        )
      end
    end

    context 'when client detained' do
      let(:application) do
        build(:prior_authority_application,
              main_offence: 'Supply a controlled drug of Class A - Heroin',
              rep_order_date: 1.month.ago.to_date,
              client_detained: true,
              client_detained_prison: 'HMP Belmarsh',
              subject_to_poca: true,
              defendant: defendant)
      end

      it 'generates expected rows' do
        expect(card.row_data).to eq(
          [
            {
              head_key: 'main_offence',
              text: 'Supply a controlled drug of Class A - Heroin',
            },
            {
              head_key: 'rep_order_date',
              text: 1.month.ago.to_date.to_fs(:stamp),
            },
            {
              head_key: 'maat',
              text: '654321',
            },
            {
              head_key: 'client_detained',
              text: 'HMP Belmarsh',
            },
            {
              head_key: 'subject_to_poca',
              text: 'Yes',
            },
          ]
        )
      end
    end
  end
end
