require 'rails_helper'

RSpec.describe MatterType do
  subject { described_class.new('ID1', 'Desc1') }

  describe '#all' do
    it 'returns a know number of outcomes' do
      expect(described_class.all.count).to eq(16)
    end
  end

  it { expect(subject.id).to eq('ID1') }
  it { expect(subject.description).to eq('Desc1') }
  it { expect(subject.name).to eq('ID1 - Desc1') }
end
