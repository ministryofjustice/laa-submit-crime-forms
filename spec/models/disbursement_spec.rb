require 'rails_helper'

RSpec.describe Disbursement do
  subject { described_class.new(attributes) }

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
