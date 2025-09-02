module Nsm
  module Steps
    class CaseOutcomeForm < ::Steps::BaseFormObject
      include LaaCrimeFormsCommon::Validators

      attribute :plea, :value_object, source: CaseOutcome
      attribute :arrest_warrant_date, :multiparam_date
      attribute :change_solicitor_date, :multiparam_date
      attribute :case_outcome_other_info, :string

      validates :plea, presence: true
      validates_inclusion_of :plea, in: CaseOutcome.values

      validates :arrest_warrant_date,
                presence: true,
                multiparam_date: { allow_past: true, allow_future: false },
                if: :arrest_warrant?

      validates :change_solicitor_date,
                presence: true,
                multiparam_date: { allow_past: true, allow_future: false },
                if: :change_solicitor?

      validates :case_outcome_other_info, presence: true, if: :other?

      def other?
        plea == CaseOutcome::OTHER
      end

      def arrest_warrant?
        plea == CaseOutcome::ARREST_WARRANT
      end

      def change_solicitor?
        plea == CaseOutcome::CHANGE_SOLICITOR
      end

      private

      def persist!
        application.update!(attributes.merge(attributes_to_reset))
      end

      def attributes_to_reset
        {
          'arrest_warrant_date' => arrest_warrant? ? arrest_warrant_date : nil,
          'change_solicitor_date' => change_solicitor? ? change_solicitor_date : nil,
          'case_outcome_other_info' => other? ? case_outcome_other_info : nil
        }
      end
    end
  end
end
