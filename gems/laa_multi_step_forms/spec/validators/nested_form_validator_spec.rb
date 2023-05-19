require 'rails_helper'

RSpec.describe NestedFormValidator do
  subject { klass.new(other_form:) }

  let(:klass) do
    Class.new(Steps::BaseFormObject) do
      attr_accessor :other_form

      validates :other_form, nested_form: true
    end
  end
  let(:other_form) { double(Steps::BaseFormObject, valid?: valid_state) }

  context 'nested form is valid' do
    let(:valid_state) { true }

    it 'form object is valid' do
      expect(subject).to be_valid
    end
  end

  context 'nested form is invalid' do
    let(:valid_state) { false }

    it 'attribute is marked as valid' do
      expect(subject).not_to be_valid
      expect(subject.errors.of_kind?(:other_form, :invalid)).to be(true)
    end
  end
end
