module Nsm
  module Tasks
    class Disbursements < Base
      PREVIOUS_TASKS = LettersCalls
      PREVIOUS_STEP_NAME = :letters_calls
      FORMS = [
        Nsm::Steps::DisbursementTypeForm,
        Nsm::Steps::DisbursementCostForm,
      ].freeze

      # TODO: is this inefficient? do we care?
      def previously_visited?
        application.navigation_stack.include?(edit_nsm_steps_disbursement_add_path(application)) ||
          [
            edit_nsm_steps_disbursement_type_path(id: application.id, disbursement_id: ''),
            edit_nsm_steps_disbursement_cost_path(id: application.id, disbursement_id: ''),
            edit_nsm_steps_disbursements_path(id: application.id),
          ].any? do |path|
            application.navigation_stack.any? { |stack| stack.start_with?(path) }
          end
      end

      # TODO: is it possible to NOT have disbursements? do we need to flag this?
      def completed?
        return true if application.has_disbursements == YesNoAnswer::NO.to_s

        application.disbursements.any? && application.disbursements.all? do |record|
          FORMS.all? { |form| super(record, form) }
        end
      end
    end
  end
end
