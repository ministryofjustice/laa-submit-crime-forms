require 'rails_helper'

RSpec.describe MultiparamDateValidator do
  let(:klass) do
    Class.new(Steps::BaseFormObject) do
      def self.name
        'MultiparamDateTest'
      end

      attribute :simple_date, :multiparam_date
      attribute :past_date, :multiparam_date
      attribute :future_date, :multiparam_date

      validates :simple_date, multiparam_date: { allow_past: true, allow_future: true }
      validates :past_date, multiparam_date: { allow_past: true, allow_future: false }
      validates :future_date, multiparam_date: { allow_past: false, allow_future: true }
    end
  end
  subject { klass.new(arguments) }

  around do |spec|
    I18n.backend.load_translations unless I18n.backend.initialized?
    attributes = %i[simple_date past_date future_date].each_with_object({}) do |date_field, hash|
      hash[date_field] =  { past_not_allowed: "Past not allowed" }
    end
    data = { activemodel: { errors: { models: { multiparam_date_test: { attributes: } } } } }
    I18n.backend.store_translations(:en, data)
    spec.run
    I18n.backend.reload!
  end

  let(:arguments) { { simple_date: nil, past_date: nil, future_date: nil } }

  shared_examples 'a multiparam date validation' do |options|
    let(:attribute_name) { options[:attribute_name] }

    before do
      subject.public_send("#{attribute_name}=", date)
    end

    context 'when day is invalid' do
      let(:date) { { 3 => 32, 2 => 12, 1 => 2020 } }

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.added?(attribute_name, :invalid_day)).to be(true)
      end
    end

    context 'when day is missing' do
      let(:date) { { 2 => 12, 1 => 2020 } }

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.added?(attribute_name, :invalid_day)).to be(true)
      end
    end

    context 'when month is invalid' do
      let(:date) { { 3 => 25, 2 => 13, 1 => 2020 } }

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.added?(attribute_name, :invalid_month)).to be(true)
      end
    end

    context 'when month is missing' do
      let(:date) { { 3 => 25, 1 => 2020 } }

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.added?(attribute_name, :invalid_month)).to be(true)
      end
    end

    context 'when year is invalid (too old)' do
      let(:date) { { 3 => 25, 2 => 12, 1 => 1899 } }

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.added?(attribute_name, :year_too_early)).to be(true)
      end
    end

    context 'when year is invalid (too futuristic)' do
      let(:date) { { 3 => 25, 2 => 12, 1 => 2051 } }

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.added?(attribute_name, :year_too_late)).to be(true)
      end
    end

    context 'when year is missing' do
      let(:date) { { 3 => 25, 2 => 12 } }

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.added?(attribute_name, :invalid_year)).to be(true)
      end
    end

    context 'when date contains garbage values' do
      let(:date) { { 3 => 'foo', 2 => 2, 1 => 'bar' } }

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.added?(attribute_name, :invalid)).to be(true)
      end
    end

    context 'when date is not valid (non-leap year)' do
      let(:date) { { 3 => 29, 2 => 2, 1 => 2021 } }

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.added?(attribute_name, :invalid)).to be(true)
      end
    end

    context 'when date is in the future' do
      let(:date) { Date.tomorrow }

      # `false` is the validator default unless passing a different config
      if options.fetch(:allow_future, false)
        it 'allows future dates' do
          expect(subject).to be_valid
          expect(subject.errors.added?(attribute_name, :future_not_allowed)).to be(false)
        end
      else
        it 'does not allow future dates' do
          expect(subject).not_to be_valid
          expect(subject.errors.added?(attribute_name, :future_not_allowed)).to be(true)
        end
      end
    end

    context 'when date is in the past' do
      let(:date) { Date.yesterday }

      # `true` is the validator default unless passing a different config
      if options.fetch(:allow_past, true)
        it 'allows past dates' do
          expect(subject).to be_valid
          expect(subject.errors.added?(attribute_name, :past_not_allowed)).to be(false)
        end
      else
        it 'does not allow past dates' do
          expect(subject).not_to be_valid
          expect(subject.errors.added?(attribute_name, :past_not_allowed)).to be(true)
        end
      end
    end
  end

  describe 'validations' do
    it_behaves_like 'a multiparam date validation',
                    attribute_name: :simple_date, allow_past: true, allow_future: true

    it_behaves_like 'a multiparam date validation',
                    attribute_name: :past_date, allow_past: true, allow_future: false

    it_behaves_like 'a multiparam date validation',
                    attribute_name: :future_date, allow_past: false, allow_future: true
  end
end
