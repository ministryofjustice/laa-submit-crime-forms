require 'rails_helper'

RSpec.describe TimePeriodValidator do
  subject { klass.new(time_spent:) }

  let(:klass) do
    Class.new(Assess::BaseViewModel) do
      def self.name
        'TimePeriodTest'
      end

      attribute :time_spent, :time_period
      validates :time_spent, time_period: true
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
        expect(subject.errors.of_kind?(:time_spent, :positive_hours)).to be(true)
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
        expect(subject.errors.of_kind?(:time_spent, :positive_minutes)).to be(true)
      end
    end
  end
end
