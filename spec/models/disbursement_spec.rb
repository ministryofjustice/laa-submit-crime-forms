require 'rails_helper'

RSpec.describe Disbursement do
  subject { described_class.new(attributes) }

  let(:attributes) { { total_cost_without_vat:, vat_amount: } }
  let(:total_cost_without_vat) { 10.0 }
  let(:vat_amount) { 0.0 }

  describe '#total_cost' do
    context 'when total_cost_without_vat is nil' do
      let(:total_cost_without_vat) { nil }

      it { expect(subject.total_cost).to be_nil }
    end

    context 'when total_cost_without_vat is not nil' do
      context 'when vat_amount is 0' do
        it 'is equal to total_cost_without_tax' do
          expect(subject.total_cost).to eq(10)
        end
      end

      context 'when vat amount is not 0' do
        let(:vat_amount) { 2.0 }

        it 'is equal to total_cost_without_tax + vat_amount' do
          expect(subject.total_cost).to eq(12)
        end
      end
    end
  end

  describe 'translated_disbursement_type' do
    context 'when not set' do
      let(:attributes) { { disbursement_type: nil } }

      it { expect(subject.translated_disbursement_type).to be_nil }
    end

    context 'when standard type' do
      let(:attributes) { { disbursement_type: 'car' } }

      it { expect(subject.translated_disbursement_type).to eq('Car mileage') }
    end

    context 'when other type' do
      let(:attributes) { { disbursement_type: 'other', other_type: 'computer_experts' } }

      it { expect(subject.translated_disbursement_type).to eq('Computer Experts') }
    end

    context 'when custom type' do
      let(:attributes) { { disbursement_type: 'other', other_type: 'Custom' } }

      it { expect(subject.translated_disbursement_type).to eq('Custom') }
    end
  end
end
