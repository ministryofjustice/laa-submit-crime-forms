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
    context 'with non standard magistrates claim' do
      let(:claim) { build(:claim, :case_type_magistrates, rep_order_date:) }
      let(:rep_order_date) { Date.new(2024, 3, 1) }

      it 'generates magistrates rows' do
        expect(subject.row_data).to match(
          [
            {
              head_key: 'laa_reference',
              text: claim.laa_reference
            },
            {
              head_key: 'file_ufn',
              text: '120423/001'
            },
            {
              head_key: 'type_of_claim',
              text: "Non-standard magistrates' court payment"
            },
            {
              head_key: 'rep_order_date',
              text: '1 March 2024'
            }
          ]
        )
      end
    end

    context 'with non standard magistrates claim without rep order date' do
      let(:claim) { build(:claim, :case_type_magistrates, rep_order_date: nil) }

      it 'allows a nil rep order date' do
        expect(subject.row_data)
          .to match(a_hash_including(head_key: 'rep_order_date', text: nil))
      end
    end

    context 'with breach of injunction claim' do
      let(:claim) { build(:claim, :case_type_breach, cntp_date:) }
      let(:cntp_date) { Date.new(2024, 2, 10) }

      it 'generates magistrates rows' do
        expect(subject.row_data).to match(
          [
            {
              head_key: 'laa_reference',
              text: claim.laa_reference
            },
            {
              head_key: 'file_ufn',
              text: '120423/002'
            },
            {
              head_key: 'type_of_claim',

              text: 'Breach of injunction'
            },
            {
              head_key: 'cntp_number',
              text: /\ACNTP\d+\z/
            },
            {
              head_key: 'cntp_rep_order',
              text: '10 February 2024'
            }
          ]
        )
      end
    end

    context 'with breach of injunction claim without contempt date' do
      let(:claim) { build(:claim, :case_type_breach, cntp_date: nil) }

      it 'allows a nil contempt date' do
        expect(subject.row_data)
          .to match(a_hash_including(head_key: 'cntp_rep_order', text: nil))
      end
    end
  end
end
