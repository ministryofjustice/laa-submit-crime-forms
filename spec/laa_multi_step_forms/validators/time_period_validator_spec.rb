require 'rails_helper'

RSpec.describe TimePeriodValidator do
  subject { klass.new(time_spent:) }

  let(:time_spent_options) { true }
  let(:klass) do
    # needs to be a local variable to allow use in class definition block
    options = time_spent_options
    Class.new(Steps::BaseFormObject) do
      def self.name
        'TimePeriodTest'
      end

      attribute :time_spent, :time_period
      validates :time_spent, time_period: options
    end
  end

  context 'when time_spent is not set' do
    let(:time_spent) { nil }

    it { expect(subject).to be_valid }
  end

  context 'when time_spent is an integer' do
    let(:time_spent) { 61 }

    it { expect(subject).to be_valid }

    context 'when time_spent is negative' do
      let(:time_spent) { -10 }

      it 'not to be valid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:time_spent, :invalid_period)).to be(true)
      end
    end

    context 'when time_spent is zero' do
      let(:time_spent) { 0 }

      it 'not to be valid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:time_spent, :zero_time_period)).to be(true)
      end

      context 'when zero values are allowed' do
        let(:time_spent_options) { { allow_zero: true } }

        it { expect(subject).to be_valid }
      end
    end
  end

  context 'when time_spent is a hash' do
    let(:time_spent) { { 1 => hours, 2 => minutes } }
    let(:hours) { 1 }
    let(:minutes) { 1 }

    context 'and is valid' do
      it { expect(subject).to be_valid }
    end

    context 'and hours is blank' do
      let(:hours) { nil }

      it 'not to be valid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:time_spent, :blank_hours)).to be(true)
      end
    end

    context 'and hours is negative' do
      let(:hours) { -1 }

      it 'not to be valid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:time_spent, :invalid_hours)).to be(true)
      end
    end

    context 'and hours is a valid string' do
      let(:hours) { '1' }

      it { expect(subject).to be_valid }
    end

    context 'and hours is a nonnumerical string' do
      let(:hours) { 'three' }

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:time_spent, :non_numerical_hours)).to be(true)
      end
    end

    context 'and hours is a non-integer numerical string' do
      let(:hours) { '3.5' }

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:time_spent, :non_integer_hours)).to be(true)
      end
    end

    context 'and minutes is blank' do
      let(:minutes) { nil }

      it 'not to be valid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:time_spent, :blank_minutes)).to be(true)
      end
    end

    context 'and minutes is invalid' do
      let(:minutes) { -1 }

      it 'not to be valid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:time_spent, :invalid_minutes)).to be(true)
      end
    end

    context 'and minutes is a valid string' do
      let(:minutes) { '1' }

      it { expect(subject).to be_valid }
    end

    context 'and minutes is a nonnumerical string' do
      let(:minutes) { 'three' }

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:time_spent, :non_numerical_minutes)).to be(true)
      end
    end

    context 'and minutes is a non-integer numerical string' do
      let(:minutes) { '3.5' }

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:time_spent, :non_integer_minutes)).to be(true)
      end
    end
  end
end
