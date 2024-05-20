require 'rails_helper'

RSpec.describe Nsm::CostSummary::Summary do
  subject { described_class.new(claim) }

  let(:claim) { create(:claim, work_items:) }

  describe '#profit_costs_net' do
    context 'when figures could be vulnerable to a floating point rounding error' do
      let(:work_items) { [build(:work_item, time_spent: 138, work_type: 'advocacy')] }

      before do
        allow(Pricing).to receive(:for).with(claim).and_return(Pricing.new('advocacy' => 24.35))
      end

      it 'generates a number that rounds correctly' do
        # 2.3 * 24.35 = £56.005 which rounds up, but using floats can result in £56.0049 which rounds down
        expect(NumberTo.pounds(subject.profit_costs_net)).to eq '£56.01'
      end
    end

    context 'when figures could be vulnerable to a decimal precision error' do
      let(:work_items) { Array.new(30) { build(:work_item, time_spent: 175, work_type: 'advocacy') } }

      before do
        allow(Pricing).to receive(:for).with(claim).and_return(Pricing.new('advocacy' => 45.35))
      end

      it 'generates a number that rounds correctly' do
        # 30 * 175 * 45.35 / 60 = £3968.125 which rounds up,
        # but using decimals can result in £3968.124999... which rounds down
        expect(NumberTo.pounds(subject.profit_costs_net)).to eq '£3,968.13'
      end
    end
  end
end
