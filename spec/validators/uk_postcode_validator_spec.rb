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
  let(:parsed_postcode) do
    double(:parsed_postcode, full_valid?: postcode_state, valid?: partial_state, outcode: postcode)
  end
  let(:postcode_state) { true }
  let(:partial_state) { true }

  context 'when mocking UKPostcode' do
    before do
      allow(UKPostcode).to receive(:parse).and_return(parsed_postcode)
    end

    context 'postcode is nil' do
      let(:postcode) { nil }

      it 'form object is valid' do
        expect(UKPostcode).not_to receive(:parse)
        expect(subject).to be_valid
      end
    end

    context 'postcode is valid' do
      it 'form object is valid' do
        expect(subject).to be_valid
      end
    end

    context 'postcode is invalid' do
      let(:postcode_state) { false }

      it 'attribute is marked as valid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:postcode, :invalid)).to be(true)
      end
    end

    context 'when partial postcodes are allowed' do
      let(:klass) do
        Class.new(Steps::BaseFormObject) do
          attribute :postcode
          validates :postcode, uk_postcode: { allow_partial: true }
        end
      end

      context 'postcode is nil' do
        let(:postcode) { nil }

        it 'form object is valid' do
          expect(UKPostcode).not_to receive(:parse)
          expect(subject).to be_valid
        end
      end

      context 'postcode is valid' do
        it 'form object is valid' do
          expect(subject).to be_valid
        end
      end

      context 'postcode is invalid' do
        let(:postcode_state) { false }
        let(:partial_state) { false }

        it 'attribute is marked as invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:postcode, :invalid)).to be(true)
        end
      end

      context 'postcode is first part only' do
        let(:postcode_state) { false }
        let(:partial_state) { true }

        it 'attribute is marked as valid' do
          expect(subject).to be_valid
        end
      end
    end
  end

  context 'when running with real validation logic' do
    context 'when partial postcodes are allowed' do
      let(:klass) do
        Class.new(Steps::BaseFormObject) do
          attribute :postcode
          validates :postcode, uk_postcode: { allow_partial: true }
        end
      end

      [
        'E',
        'e',
        '1E',
        '1',
        'E12a',
        'IP22 3'
      ].each do |invalid|
        context "with an invalid partial '#{invalid}'" do
          let(:postcode) { invalid }

          it 'marks the attribute as invalid' do
            expect(subject).not_to be_valid
          end
        end
      end

      %w[
        E1
        e1
        SW1V
        GU3
        N16
      ].each do |invalid|
        context "with a valid partial '#{invalid}'" do
          let(:postcode) { invalid }

          it 'marks the attribute as valid' do
            expect(subject).to be_valid
          end
        end
      end
    end
  end
end
