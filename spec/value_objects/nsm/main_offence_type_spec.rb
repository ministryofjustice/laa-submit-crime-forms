require 'rails_helper'

RSpec.describe MainOffenceType do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(
        %w[
          summary_only
          either_way
          indictable_only
          prescribed_proceedings
        ]
      )
    end
  end
end
