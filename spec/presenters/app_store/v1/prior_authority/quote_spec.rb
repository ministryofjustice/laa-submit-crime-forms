require 'rails_helper'

RSpec.describe AppStore::V1::PriorAuthority::Quote do
  describe '#base_cost_allowed' do
    it 'sums per-hour costs' do
      instance = described_class.new(
        'cost_type' => 'per_hour',
        'cost_per_hour' => '20.15',
        'period' => 30
      )

      expect(instance.base_cost_allowed).to eq 10.08
    end

    it 'sums per-item costs' do
      instance = described_class.new(
        'cost_type' => 'per_item',
        'cost_per_item' => '20.15',
        'items' => 2
      )

      expect(instance.base_cost_allowed).to eq 40.30
    end
  end

  describe '#travel_cost_allowed' do
    it 'sums per-hour costs' do
      instance = described_class.new(
        'travel_cost_per_hour' => '20.15',
        'travel_time' => 30
      )

      expect(instance.travel_cost_allowed).to eq 10.08
    end

    it 'can handle blanks' do
      instance = described_class.new({})
      expect(instance.travel_cost_allowed).to eq 0.0
    end
  end
end
