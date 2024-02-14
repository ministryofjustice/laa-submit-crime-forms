require 'rails_helper'

RSpec.describe IsANumberValidator do
  subject { klass.new(item:) }

  let(:klass) do
    Class.new(Steps::BaseFormObject) do
      attribute :item
      validates :item, is_a_number: true
    end
  end

  context 'attribute is nil' do
    let(:item) { nil }

    it 'form object is valid' do
      expect(subject).to be_valid
    end
  end

  context 'attribute is a number' do
    let(:item) { 123.45 }

    it 'form object is valid' do
      expect(subject).to be_valid
    end
  end

  context 'attribute is a string' do
    let(:item) { 'four thousand' }

    it 'attribute is marked as valid' do
      expect(subject).not_to be_valid
      expect(subject.errors.of_kind?(:item, :not_a_number)).to be(true)
    end
  end
end
