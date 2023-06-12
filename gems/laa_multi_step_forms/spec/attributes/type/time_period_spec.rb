require 'rails_helper'

RSpec.describe Type::TimePeriod do
  describe '#cast' do
    let(:result) { subject.cast(value) }

    context 'when value is a hash' do
      context 'that is valid' do
        let(:value) { { 1 => 1, 2 => 2 } }

        it 'converts the hash into Instance with the in integer minutes' do
          expect(result).to be_a(described_class::Instance)
          expect(result).to eq(62)
        end
      end

      context 'that is invalid' do
        let(:value) { { a: 1, b: 2 } }

        it 'returns the hash without modification' do
          value_copy = value.dup
          expect(result).to eq(value_copy)
        end
      end
    end

    context 'when value is an integer' do
      let(:value) { 12 }

      it 'returns a new Instance with that value' do
        expect(result).to be_a(described_class::Instance)
        expect(result).to eq(12)
      end
    end
  end

  describe '#serialize' do
    it 'returns the value passed in' do
      expect(subject.serialize(12)).to eq(12)
    end
  end
end

RSpec.describe Type::TimePeriod::Instance do
  subject { described_class.new(value) }

  describe '#hours' do
    context 'when value is nil' do
      let(:value) { nil }
      it { expect(subject.hours).to eq(nil) }
    end

    context 'when value is an integer' do
      let(:value) { 62 }
      it { expect(subject.hours).to eq(1) }
    end
  end

  describe '#minutes' do
    context 'when value is nil' do
      let(:value) { nil }
      it { expect(subject.minutes).to eq(nil) }
    end

    context 'when value is an integer' do
      let(:value) { 62 }
      it { expect(subject.minutes).to eq(2) }
    end
  end

  describe '#valid?' do
    let(:value) { nil }
    it { expect(subject).to be_valid }
  end
end
