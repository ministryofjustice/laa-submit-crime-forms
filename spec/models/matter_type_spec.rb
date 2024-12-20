require 'rails_helper'

RSpec.describe MatterType do
  subject { described_class.new('1') }

  describe '#all' do
    # rubocop:disable Rails/RedundantActiveRecordAllMethod
    it 'returns a know number of outcomes' do
      expect(described_class.all.count).to eq(16)
    end
    # rubocop:enable Rails/RedundantActiveRecordAllMethod
  end

  it { expect(subject.id).to eq('1') }
  it { expect(subject.description).to eq('Offences against the person') }
  it { expect(subject.name).to eq('1 - Offences against the person') }
end
