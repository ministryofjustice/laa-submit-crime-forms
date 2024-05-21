require 'rails_helper'

RSpec.describe LaaMultiStepForms::Court, type: :model do
  describe '.all' do
    subject { described_class.all }

    it 'returns required courts as expected' do
      digest_of_expected_court_names = '288c887f6a9965d43e9c6b8766424d5f'

      expect(Digest::MD5.hexdigest(subject.map(&:name).join)).to eq digest_of_expected_court_names
    end
  end

  describe '#==' do
    subject { described_class.new(name: 'check_against') }

    context 'when other object is the same value' do
      it { expect(subject).to eq(described_class.new(name: 'check_against')) }
    end

    context 'when other object has a different value' do
      it { expect(subject).not_to eq(described_class.new(name: 'different')) }
    end
  end
end
