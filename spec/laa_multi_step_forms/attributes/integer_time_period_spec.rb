require 'rails_helper'

RSpec.describe IntegerTimePeriod do
  subject { described_class.new(value) }

  describe '#hours' do
    context 'when value is nil' do
      let(:value) { nil }

      it { expect(subject.hours).to be_nil }
    end

    context 'when value is an integer' do
      let(:value) { 62 }

      it { expect(subject.hours).to eq(1) }
    end
  end

  describe '#minutes' do
    context 'when value is nil' do
      let(:value) { nil }

      it { expect(subject.minutes).to be_nil }
    end

    context 'when value is an integer' do
      let(:value) { 62 }

      it { expect(subject.minutes).to eq(2) }
    end
  end
end
