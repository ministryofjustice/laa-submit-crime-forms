require 'rails_helper'

RSpec.describe Nsm::Steps::CaseOutcomeForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      plea:,
      arrest_warrant_date:,
      change_solicitor_date:,
      case_outcome_other_info:,
    }
  end

  let(:application) { instance_double(Claim) }
  let(:arrest_warrant_date) { nil }
  let(:change_solicitor_date) { nil }
  let(:case_outcome_other_info) { nil }

  describe '#validations' do
    context 'when plea is blank' do
      let(:plea) { '' }

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:plea, :inclusion)).to be(true)
      end
    end

    context 'when `claim_type` is invalid' do
      let(:plea) { 'invalid_type' }

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:plea, :inclusion)).to be(true)
      end
    end

    context 'when the outcome is a warrant for arrest' do
      let(:plea) { CaseOutcome::ARREST_WARRANT.to_s }

      context 'and the date is set' do
        let(:arrest_warrant_date) { Date.new(2023, 4, 1) }

        it 'is valid' do
          expect(subject).to be_valid
        end

        it 'can reset the fields except the date' do
          attributes = subject.send(:attributes_to_reset)
          expect(attributes).to include(
            'arrest_warrant_date' => arrest_warrant_date,
            'case_outcome_other_info' => nil,
            'change_solicitor_date' => nil,
          )
        end
      end

      context 'and the date is not set' do
        let(:arrest_warrant_date) { nil }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:arrest_warrant_date, :blank)).to be(true)
        end
      end

      context 'and the date is in the future' do
        let(:arrest_warrant_date) { 3.days.from_now.to_date }

        it 'throws a validation error' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:arrest_warrant_date, :future_not_allowed)).to be(true)
        end
      end

      context 'and the date is too far past' do
        let(:arrest_warrant_date) { Date.new(1899, 4, 1) }

        it 'throws a validation error' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:arrest_warrant_date, :year_too_early)).to be(true)
        end
      end
    end

    context 'when the outcome is change of solicitor' do
      let(:plea) { CaseOutcome::CHANGE_SOLICITOR.to_s }

      context 'and the date is set' do
        let(:change_solicitor_date) { Date.new(2023, 4, 1) }
        let(:arrest_warrant_date) { Date.new(2023, 4, 1) }
        let(:case_outcome_other_info) { 'test' }

        it 'is valid' do
          expect(subject).to be_valid
        end

        it 'can reset the fields except the date' do
          attributes = subject.send(:attributes_to_reset)
          expect(attributes).to include(
            'arrest_warrant_date' => nil,
            'case_outcome_other_info' => nil,
            'change_solicitor_date' => change_solicitor_date,
          )
        end
      end

      context 'without a date set' do
        it 'throws a validation error' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:change_solicitor_date, :blank)).to be(true)
        end
      end

      context 'and the date is in the future' do
        let(:change_solicitor_date) { 3.days.from_now.to_date }

        it 'throws a validation error' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:change_solicitor_date, :future_not_allowed)).to be(true)
        end
      end

      context 'and the date is too far past' do
        let(:change_solicitor_date) { Date.new(1899, 4, 1) }

        it 'throws a validation error' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:change_solicitor_date, :year_too_early)).to be(true)
        end
      end
    end
  end

  context 'when the outcome is other' do
    let(:plea) { CaseOutcome::OTHER.to_s }

    context 'and the custom outcome is set' do
      let(:change_solicitor_date) { Date.new(2023, 4, 1) }
      let(:arrest_warrant_date) { Date.new(2023, 4, 1) }
      let(:case_outcome_other_info) { 'test' }

      it 'is valid' do
        expect(subject).to be_valid
      end

      it 'can reset the fields except the custom outcome' do
        attributes = subject.send(:attributes_to_reset)
        expect(attributes).to include(
          'arrest_warrant_date' => nil,
          'case_outcome_other_info' => case_outcome_other_info,
          'change_solicitor_date' => nil,
        )
      end
    end

    context 'without a custom outcome set' do
      it 'throws a validation error' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:case_outcome_other_info, :blank)).to be(true)
      end
    end
  end
end
