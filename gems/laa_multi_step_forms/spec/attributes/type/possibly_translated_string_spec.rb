require 'rails_helper'

RSpec.describe Type::PossiblyTranslatedString do
  subject { described_class.new }

  let(:coerced_value) { subject.cast(value) }

  describe 'when value is `nil`' do
    let(:value) { nil }

    it { expect(coerced_value).to be_nil }
  end

  describe 'when value is a string' do
    let(:value) { 'foo' }

    it { expect(coerced_value).to eq('foo') }
  end

  describe 'when value is a translation' do
    let(:value) { { 'en' => 'Foo', 'value' => 'foo' } }

    it { expect(coerced_value).to eq 'foo' }
  end
end
