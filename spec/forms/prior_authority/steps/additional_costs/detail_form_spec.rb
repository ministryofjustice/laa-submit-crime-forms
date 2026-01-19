require 'rails_helper'

RSpec.describe PriorAuthority::Steps::AdditionalCosts::DetailForm do
  subject { described_class.new(attributes) }

  describe '#total_cost' do
    context 'per hour unit type' do
      let(:attributes) { { unit_type: 'per_hour', cost_per_hour: 10, period: 60 } }

      it 'calculates total_cost correctly' do
        expect(subject.total_cost).to eq(10.00)
      end

      context 'and cost_per_item is not a valid decimal' do
        let(:attributes) { { unit_type: 'per_hour', cost_per_hour: '1apple', period: 60 } }

        it 'calculates the cost as 0' do
          expect(subject.total_cost).to eq(0.00)
        end
      end
    end

    context 'per item unit type' do
      let(:attributes) { { unit_type: 'per_item', cost_per_item: 10, items: 2 } }

      it 'calculates total_cost correctly' do
        expect(subject.total_cost).to eq(20.00)
      end

      context 'and cost_per_item is not a valid decimal' do
        let(:attributes) { { unit_type: 'per_item', cost_per_item: '1apple', items: 2 } }

        it 'calculates the cost as 0' do
          expect(subject.total_cost).to eq(0.00)
        end
      end

      context 'and item count is negative' do
        let(:attributes) { { unit_type: 'per_item', cost_per_item: '10', items: '-2' } }

        it 'calculates the cost as 0' do
          expect(subject.total_cost).to eq(0.00)
        end
      end
    end

    context 'no unit type' do
      let(:attributes) { { unit_type: nil } }

      it 'calculates total_cost correctly' do
        expect(subject.total_cost).to eq(0)
      end
    end
  end

  describe '#validation' do
    context 'when per_item items exceed the integer limit' do
      let(:attributes) { { unit_type: 'per_item', cost_per_item: 10, items: NumericLimits::MAX_INTEGER + 1 } }

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:items, :less_than_or_equal_to)).to be(true)
      end
    end
  end
end
