require 'rails_helper'

RSpec.describe UkPostcodeValidator do
  subject { klass.new(postcode:) }

  let(:postcode) { 'AA1 2BB' }
  let(:klass) do
    Class.new(Steps::BaseFormObject) do
      attribute :postcode
      validates :postcode, uk_postcode: true
    end
  end
  let(:parsed_postcode) { double(:parsed_postcode, full_valid?: postcode_state) }

  before do
    allow(UKPostcode).to receive(:parse).and_return(parsed_postcode)
  end

  context 'nested form is valid' do
    let(:postcode_state) { true }

    it 'form object is valid' do
      expect(subject).to be_valid
    end
  end

  context 'nested form is invalid' do
    let(:postcode_state) { false }

    it 'attribute is marked as valid' do
      expect(subject).not_to be_valid
      expect(subject.errors.of_kind?(:postcode, :invalid)).to be(true)
    end
  end
end
