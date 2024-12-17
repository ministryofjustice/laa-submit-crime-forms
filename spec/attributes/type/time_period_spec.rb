require 'rails_helper'

RSpec.describe Type::TimePeriod do
  describe '#cast' do
    let(:result) { subject.cast(value) }

    context 'when value is a hash' do
      context 'that is valid' do
        let(:value) { { 1 => 1, 2 => 2 } }

        it 'converts the hash into a IntegerTimePeriod with the in integer minutes' do
          expect(result).to be_a(IntegerTimePeriod)
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

      it 'returns a new IntegerTimePeriod with that value' do
        expect(result).to be_a(IntegerTimePeriod)
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
