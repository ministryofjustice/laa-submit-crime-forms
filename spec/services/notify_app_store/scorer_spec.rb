require 'rails_helper'

RSpec.describe NotifyAppStore::Scorer do
  describe '#calculate' do
    it 'returns high' do
      expect(described_class.calculate(double)).to eq('high')
    end
  end
end