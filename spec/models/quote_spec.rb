require 'rails_helper'

RSpec.describe Quote do
  subject { described_class.new(attributes) }

  describe '#total_cost' do
    context 'per hour unit type' do
      let(:attributes) { { cost_per_hour: 10, period: 60, travel_cost_per_hour: 10, travel_time: 60} }

      it 'calculates total_cost correctly' do
        expect(subject.total_cost).to eq(20.00)
      end
    end

    context 'per item unit type' do
      let(:attributes) { { cost_per_item: 10, items: 2, travel_cost_per_hour: 10, travel_time: 60} }

      it 'calculates total_cost correctly' do
        expect(subject.total_cost).to eq(30.00)
      end
    end

    context 'no unit type' do
      let(:attributes) { { cost_per_item: nil, cost_per_hour: nil, travel_cost_per_hour: 10, travel_time: 60 } }

      it 'calculates total_cost correctly' do
        expect(subject.total_cost).to eq(10.00)
      end
    end
  end
end
