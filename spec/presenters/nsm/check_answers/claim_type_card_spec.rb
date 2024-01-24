# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nsm::CheckAnswers::ClaimTypeCard do
  subject { described_class.new(claim) }

  describe '#title' do
    let(:claim) { build(:claim) }

    it 'shows correct title' do
      expect(subject.title).to eq('What you are claiming for')
    end
  end

  describe '#row_data' do
    context 'non standard magistrates claim' do
      let(:claim) { build(:claim, :case_type_magistrates) }

      it 'generates magistrates rows' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'file_ufn',
              text: '123456/001'
            },
            {
              head_key: 'type_of_claim',
              text: "Non-standard magistrates' court payment"
            },
            {
              head_key: 'rep_order_date',
              text: '01 January 2023'
            }
          ]
        )
      end
    end

    context 'breach of injunction claim' do
      let(:claim) { build(:claim, :case_type_breach) }

      it 'generates magistrates rows' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'file_ufn',
              text: '123456/002'
            },
            {
              head_key: 'type_of_claim',

              text: 'Breach of injunction'
            },
            {
              head_key: 'cntp_number',
              text: 'CNTP12345'
            },
            {
              head_key: 'cntp_rep_order',
              text: '01 February 2023'
            }
          ]
        )
      end
    end
  end
end
