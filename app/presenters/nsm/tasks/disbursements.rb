module Nsm
  module Tasks
    class Disbursements < Base
      PREVIOUS_TASKS = LettersCalls
      PREVIOUS_STEP_NAME = :letters_calls
      FORMS = [
        Nsm::Steps::DisbursementTypeForm,
        Nsm::Steps::DisbursementCostForm,
      ].freeze

      def previously_visited?
        application.viewed_steps.intersect?(%w[disbursement_add disbursements])
      end

      def completed?
        return true if application.has_disbursements == YesNoAnswer::NO.to_s

        application.disbursements.any? && application.disbursements.all?(&:complete?)
      end
    end
  end
end
