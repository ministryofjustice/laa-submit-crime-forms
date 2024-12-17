require 'rails_helper'

RSpec.describe YesNoAnswer do
  describe '.values' do
    subject(:values) { described_class.values }

    it 'returns all possible values' do
      expect(values.map(&:to_s)).to eq(%w[yes no])
    end
  end

  describe '.radio_options' do
    subject(:radio_options) { described_class.radio_options }

    it 'returns array of values an labels' do
      expect(radio_options.map(&:label)).to match_array(%w[Yes No])
    end
  end
end
