require 'rails_helper'

RSpec.describe Claim do
  subject { described_class.new(attributes) }

  describe '#date' do
    context 'when rep_order_date is set' do
      let(:attributes) { { rep_order_date: } }
      let(:rep_order_date) { Date.yesterday }

      it 'returns the rep_order_date' do
        expect(subject.date).to eq(rep_order_date)
      end
    end

    context 'when cntp_date is set' do
      let(:attributes) { { cntp_date: } }
      let(:cntp_date) { Date.yesterday }

      it 'returns the cntp_date' do
        expect(subject.date).to eq(cntp_date)
      end
    end

    context 'when neither rep_order_date or cntp_date is set' do
      let(:attributes) { {} }

      it 'returns nil' do
        expect(subject.date).to be_nil
      end
    end
  end

  context 'short_id' do
    let(:attributes) { { id: SecureRandom.uuid } }

    it 'returns the first 8 characters of the id' do
      expect(subject.short_id).to eq(subject.id.first(8))
    end
  end

  describe '#main_defendant' do
    subject(:saved_claim) { create(:claim, :main_defendant) }

    it 'returns the main defendant' do
      expect(saved_claim.main_defendant).to eq saved_claim.defendants.find_by(main: true)
    end
  end

  describe '#disbursement_position' do
    let(:claim) { create(:claim, disbursements:) }

    let(:disbursements) { [disbursement_a, disbursement_b, disbursement_c, disbursement_d, disbursement_e, disbursement_f] }
    let(:disbursement_a) { build(:disbursement, :valid_other, :dna_testing, age: 3) }
    let(:disbursement_b) { build(:disbursement, :valid, :bike, age: 5) }
    let(:disbursement_c) { build(:disbursement, :valid_other, :dna_testing, age: 4) }
    let(:disbursement_d) { build(:disbursement, :valid_other, other_type: 'testerization', age: 4) }
    let(:disbursement_e) { build(:disbursement, :valid_other, other_type: 'Witness', age: 4, created_at: 1.day.ago) }
    let(:disbursement_f) { build(:disbursement, :valid_other, other_type: 'witness', age: 4, created_at: 2.days.ago) }

    # sorting is by date asc, type asc (case insensitive) and created_at asc
    it 'returns 1-based index of disbursement after sorting by date asc, type asc (case insensitive) and created_at asc' do
      sorted_positions = [
        claim.disbursement_position(disbursement_b),
        claim.disbursement_position(disbursement_c),
        claim.disbursement_position(disbursement_d),
        claim.disbursement_position(disbursement_f),
        claim.disbursement_position(disbursement_e),
        claim.disbursement_position(disbursement_a),
      ]

      expect(sorted_positions).to eql [1, 2, 3, 4, 5, 6]
    end
  end
end
