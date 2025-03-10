require 'rails_helper'

RSpec.describe CompressionService do
  describe '#compress' do
    it 'creates valid data' do
      expect(described_class.compress('test')).to eq('eJxTKkktLlECAAcNAgU=')
    end
  end

  describe '#decompress' do
    it 'decodes valid data' do
      expect(described_class.decompress('eJxTKkktLlECAAcNAgU=')).to eq('test')
    end
  end
end
