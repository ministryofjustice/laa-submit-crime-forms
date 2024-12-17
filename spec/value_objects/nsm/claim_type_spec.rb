require 'rails_helper'

RSpec.describe ClaimType do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(
        %w[
          non_standard_magistrate
          breach_of_injunction
        ]
      )
    end
  end
end
