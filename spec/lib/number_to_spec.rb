require 'rails_helper'

RSpec.describe NumberTo do
  context 'when a single number is passed in' do
    it 'converts it to a money amount' do
      expect(described_class.pounds(10)).to eq('£10.00')
      expect(described_class.pounds(1_000)).to eq('£1,000.00')
      expect(described_class.pounds(1_000_000)).to eq('£1,000,000.00')
    end
  end

  context 'multople numbers are passed in' do
    it 'sums them and converts to a money amount' do
      expect(described_class.pounds(10, 10, 10)).to eq('£30.00')
      expect(described_class.pounds(1_000, 1_000)).to eq('£2,000.00')
      expect(described_class.pounds(1_000_000, 1_000_000, 500_000)).to eq('£2,500,000.00')
    end

    context 'and any of them are nil' do
      it 'returns the pound symbol' do
        expect(described_class.pounds(nil, 10, 10)).to eq('£')
        expect(described_class.pounds(10, nil, 10)).to eq('£')
        expect(described_class.pounds(10, 10, nil)).to eq('£')
        expect(described_class.pounds(nil)).to eq('£')
      end
    end
  end
end
