require 'rails_helper'

RSpec.describe CaseOutcome do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(
        %w[
          guilty
          discontinuance
          arrest_warrant
          change_solicitor
          other
          contested_trial
        ]
      )
    end
  end

  describe 'CATEGORY_1_OUTCOMES' do
    it 'returns all category 1 outcomes' do
      expect(described_class::CATEGORY_1_OUTCOMES.map(&:to_s)).to eq(
        %w[
          guilty
          discontinuance
          arrest_warrant
          change_solicitor
          other
        ]
      )
    end
  end

  describe 'CATEGORY_2_OUTCOMES' do
    it 'returns all category 2 outcomes' do
      expect(described_class::CATEGORY_2_OUTCOMES.map(&:to_s)).to eq(
        %w[
          contested_trial
          discontinuance
          other
        ]
      )
    end
  end

  describe 'HAS_DATE_FIELD' do
    it 'returns date stampable values' do
      expect(described_class::HAS_DATE_FIELD.map(&:to_s)).to eq(
        %w[
          arrest_warrant
          change_solicitor
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
