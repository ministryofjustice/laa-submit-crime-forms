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

  describe 'SUPPORTED' do
    it 'returns date stampable values' do
      expect(described_class::SUPPORTED.map(&:to_s)).to eq(
        %w[
          non_standard_magistrate
          breach_of_injunction
        ]
      )
    end
  end

  describe '#supported?' do
    context 'for SUPPORTED case types' do
      it 'returns true' do
        supported_types = described_class::SUPPORTED

        expect(
          supported_types.map(&:supported?)
        ).to all(be_truthy)
      end
    end

    context 'for non date stampable case types' do
      it 'returns false' do
        non_supported_types = described_class.values - described_class::SUPPORTED

        expect(
          non_supported_types.map(&:supported?)
        ).to all(be_falsy)
      end
    end
  end
end
