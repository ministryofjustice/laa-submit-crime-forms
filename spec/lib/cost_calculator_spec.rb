require 'rails_helper'

RSpec.describe CostCalculator do
  subject { described_class.cost(type, object, scope) }

  let(:scope) { nil }

  context 'when type is unknownn' do
    let(:type) { :unknonwn }
    let(:object) { nil }

    it { expect(subject).to be_nil }
  end

  context 'when type is work_item' do
    let(:type) { :work_item }
    let(:scope) { :provider_requested }

    context 'when uplift is present' do
      let(:object) { Assess::V1::WorkItem.new('time_spent' => 90, 'pricing' => 24.4, 'uplift' => 25) }

      it 'calculates the time * price * uplift' do
        expect(subject).to eq(45.75) # (90 / 60) * 24.4 * (125 / 100)
      end
    end

    context 'when uplift is not set' do
      let(:object) { Assess::V1::WorkItem.new('time_spent' => 90, 'pricing' => 24.4, 'uplift' => nil) }

      it 'calculates the time * price' do
        expect(subject).to eq(36.6) # (90 / 60) * 24.4
      end
    end
  end

  context 'when type is disbursement' do
    let(:type) { :disbursement }

    context 'and type is other' do
      let(:object) do
        Assess::V1::Disbursement.new('disbursement_type' => { 'value' => 'other' }, 'total_cost_without_vat' => 45.0,
                                     'vat_amount' => 20.0)
      end

      it { expect(subject).to eq(65.0) }
    end
  end

  context 'when type is letters and calls' do
    let(:type) { :letter_and_call }
    let(:object) do
      Assess::V1::LetterAndCall.new('type' => { 'en' => 'Letters', 'value' => 'letters' },
                                    'count' => 12, 'uplift' => 0, 'pricing' => 3.56)
    end
    let(:scope) { :provider_requested }

    it { expect(subject).to eq(42.72) }
  end
end
