require 'rails_helper'

RSpec.describe Nsm::Steps::DefendantSummaryForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      add_another:,
    }
  end

  let(:application) { create(:claim, defendants:) }
  let(:defendants) { [main_defendant, additional_defendant] }
  let(:main_defendant) { build(:defendant, :valid) }
  let(:additional_defendant) { build(:defendant, :additional) }
  let(:add_another) { 'yes' }

  describe '#save' do
    it 'returns true' do
      expect(subject.save).to be true
    end

    context 'when main defendant is invalid' do
      let(:main_defendant) { build(:defendant, :valid, first_name: nil) }

      it 'returns false' do
        expect(subject.save).to be false
      end

      it 'adds an appropriate error' do
        subject.save
        expect(subject.errors[:add_another]).to include(
          'You cannot save and continue if any defendant details are incomplete'
        )
      end
    end

    context 'when additional defendant is invalid' do
      let(:additional_defendant) { build(:defendant, :additional, maat: '123456') }

      it 'returns false' do
        expect(subject.save).to be false
      end

      it 'adds an appropriate error' do
        subject.save
        expect(subject.errors[:add_another]).to include(
          'You cannot save and continue if any defendant details are incomplete'
        )
      end
    end
  end
end
