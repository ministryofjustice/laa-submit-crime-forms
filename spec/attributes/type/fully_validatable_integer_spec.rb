require 'rails_helper'

RSpec.describe Type::FullyValidatableInteger do
  subject { described_class.new }

  let(:coerced_value) { subject.cast(value) }

  describe 'when value is `nil`' do
    let(:value) { nil }

    it { expect(coerced_value).to be_nil }
  end

  describe 'when value is a number' do
    let(:value) { 12_345 }

    it { expect(coerced_value).to eq(12_345) }
  end

  describe 'when value is an empty string' do
    let(:value) { '' }

    it { expect(coerced_value).to be_nil }
  end

  describe 'when value is an integery string' do
    let(:value) { '123' }

    it { expect(coerced_value).to eq 123 }
  end

  describe 'when value is an floaty string' do
    let(:value) { '123.45' }

    it { expect(coerced_value).to eq '123.45' }
  end

  describe 'when value is an numbery string with commas' do
    let(:value) { '1,234' }

    it { expect(coerced_value).to eq 1234 }
  end

  describe 'when value is non-numbery string' do
    let(:value) { 'four thousand' }

    it { expect(coerced_value).to eq 'four thousand' }
  end
end
