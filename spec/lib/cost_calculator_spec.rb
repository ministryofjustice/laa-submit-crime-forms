require 'rails_helper'

RSpec.describe CostCalculator do
  subject { described_class.cost(type, object, vat) }

  let(:object) { create(:claim, :travel_and_waiting) }
  let(:vat) { true }
  let(:pricing) { instance_double(Pricing, '[]': price, vat: vat_rate) }
  let(:price) { 0.45 }
  let(:vat_rate) { 0.2 }

  context 'when type is unknown' do
    let(:type) { :unknown }

    it { expect(subject).to be_nil }
  end

  context 'when type is travel_and_waiting_total' do
    before do
      allow(Pricing).to receive(:for).and_return(pricing)
    end

    let(:type) { :travel_and_waiting_total }

    context 'when vat is true' do
      it 'calculates the sum total cost for each travel and waiting work item with vat' do
        expect(subject).to eq(1.98)
      end
    end

    context 'when vat is false' do
      let(:vat) { false }

      it 'calculates the sum total cost for each travel and waiting work item' do
        expect(subject).to eq(1.65)
      end
    end
  end
end
