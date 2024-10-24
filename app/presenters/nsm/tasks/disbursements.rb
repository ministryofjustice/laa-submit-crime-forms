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
        application.navigation_stack.include?(edit_nsm_steps_disbursement_add_path(application)) ||
          application.navigation_stack.include?(edit_nsm_steps_disbursements_path(application))
      end

      def completed?
        return true if application.has_disbursements == YesNoAnswer::NO.to_s

        application.disbursements.any? && application.disbursements.all?(&:complete?)
      end
    end
  end
end
