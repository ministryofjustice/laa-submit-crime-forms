require 'rails_helper'

RSpec.describe UfnValidator do
  subject { klass.new(ufn:, blankable_ufn:) }

  let(:ufn) { '310124/001' }
  let(:blankable_ufn) { '310124/001' }
  let(:klass) do
    Class.new(Steps::BaseFormObject) do
      def self.name
        'UfnTest'
      end

      attribute :ufn, :string
      validates :ufn, presence: true, ufn: true
      attribute :blankable_ufn, :string
      validates :blankable_ufn, ufn: true
    end
  end

  context 'when ufn and blankable_ufn are valid' do
    it { expect(subject).to be_valid }
  end

  context 'when ufn is not set' do
    let(:ufn) { nil }

    it 'is not valid' do
      expect(subject).not_to be_valid
      expect(subject.errors.of_kind?(:ufn, :blank)).to be(true)
    end
  end

  context 'when blankable_ufn is not set' do
    let(:blankable_ufn) { nil }

    it { expect(subject).to be_valid }
  end

  context 'when ufn date is today' do
    let(:ufn) { "#{Time.zone.today.strftime('%d%m%y')}/001" }

    it { expect(subject).to be_valid }
  end

  context 'when ufn date is in the future' do
    let(:ufn) { "#{Date.tomorrow.strftime('%d%m%y')}/001" }

    it 'is not valid' do
      expect(subject).not_to be_valid
      expect(subject.errors.of_kind?(:ufn, :future_date)).to be(true)
    end
  end

  context 'when ufn is not valid' do
    context 'and contains non digits' do
      let(:ufn) { 'aaaaaa/aaa' }

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:ufn, :invalid_characters)).to be(true)
      end
    end

    context 'and is the wrong number of digits' do
      let(:ufn) { '50555/111' }

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:ufn, :invalid)).to be(true)
      end
    end

    context 'and is not a valid date' do
      let(:ufn) { '290223/111' }

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:ufn, :invalid)).to be(true)
      end
    end
  end
end
