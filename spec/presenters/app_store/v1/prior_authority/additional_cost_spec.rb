require 'rails_helper'

RSpec.describe AppStore::V1::PriorAuthority::AdditionalCost do
  describe '#total_cost_allowed' do
    it 'sums per-hour costs' do
      instance = described_class.new(
        'unit_type' => 'per_hour',
        'cost_per_hour' => '20.15',
        'period' => 30
      )

      expect(instance.total_cost_allowed).to eq 10.08
    end

    it 'sums per-item costs' do
      instance = described_class.new(
        'unit_type' => 'per_item',
        'cost_per_item' => '20.15',
        'items' => 2
      )

      expect(instance.total_cost_allowed).to eq 40.30
    end
  end
end
