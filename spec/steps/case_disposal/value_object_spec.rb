require 'rails_helper'

RSpec.describe PleaOptions do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(
        %w[
          guilty
          uncontested_breach
          discontinuance
          bind_over
          deferred_sentence
          change_solicitor
          arrest_warrant
          not_guilty
          cracked_trial
          contested
          discontinuance
          mixed
        ]
      )
    end
  end

  describe 'GUILTY_OPTIONS' do
    it 'returns date stampable values' do
      expect(described_class::GUILTY_OPTIONS.map(&:to_s)).to eq(
        %w[
          guilty
          uncontested_breach
          discontinuance
          bind_over
          deferred_sentence
          change_solicitor
          arrest_warrant
        ]
      )
    end
  end

  describe 'NOT_GUILTY_OPTIONS' do
    it 'returns date stampable values' do
      expect(described_class::NOT_GUILTY_OPTIONS.map(&:to_s)).to eq(
        %w[
          not_guilty
          cracked_trial
          contested
          discontinuance
          mixed
        ]
      )
    end
  end

  describe 'HAS_DATE_FIELD' do
    it 'returns date stampable values' do
      expect(described_class::HAS_DATE_FIELD.map(&:to_s)).to eq(
        %w[
          arrest_warrant
          cracked_trial
        ]
      )
    end
  end

  describe '#requires_date_field?' do
    context 'for HAS_DATE_FIELD pleas' do
      it 'returns true' do
        date_types = described_class::HAS_DATE_FIELD

        expect(
          date_types.map(&:requires_date_field?)
        ).to all(be_truthy)
      end
    end

    context 'for non date pleas' do
      it 'returns false' do
        non_date_types = described_class.values - described_class::HAS_DATE_FIELD

        expect(
          non_date_types.map(&:requires_date_field?)
        ).to all(be_falsy)
      end
    end
  end
end
