require 'rails_helper'

RSpec.describe AdditionalCost do
  subject { described_class.new(attributes) }

  describe '#total_cost' do
    context 'per hour unit type' do
      let(:attributes) { { unit_type: 'per_hour', cost_per_hour: 10, period: 60 } }

      it 'calculates total_cost correctly' do
        expect(subject.total_cost).to eq(10.00)
      end
    end

    context 'per item unit type' do
      let(:attributes) { { unit_type: 'per_item', cost_per_item: 10, items: 2 } }

      it 'calculates total_cost correctly' do
        expect(subject.total_cost).to eq(20.00)
      end
    end

    context 'no unit type' do
      let(:attributes) { { unit_type: nil } }

      it 'calculates total_cost correctly' do
        expect(subject.total_cost).to eq(0)
      end
    end
  end
end
