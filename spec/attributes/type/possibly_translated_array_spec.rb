require 'rails_helper'

RSpec.describe Type::PossiblyTranslatedArray do
  subject { described_class.new }

  let(:coerced_value) { subject.cast(value) }

  describe 'when value is `nil`' do
    let(:value) { nil }

    it { expect(coerced_value).to be_nil }
  end

  describe 'when value is empty' do
    let(:value) { [] }

    it { expect(coerced_value).to eq([]) }
  end

  describe 'when value is a string array' do
    let(:value) { ['foo'] }

    it { expect(coerced_value).to eq(['foo']) }
  end

  describe 'when value is a translation array' do
    let(:value) { [{ 'en' => 'Foo', 'value' => 'foo' }] }

    it { expect(coerced_value).to eq ['foo'] }
  end
end
