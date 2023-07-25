module Tasks
  class Disbursements < Generic
    PREVIOUS_TASK = LettersCalls
    PREVIOUS_STEP_NAME = :letters_calls
    FORMS = [
      Steps::DisbursementTypeForm,
      Steps::DisbursementCostForm,
    ].freeze

    # TODO: is this inefficient? do we care?
    def in_progress?
      [
        edit_steps_disbursement_type_path(id: application.id, disbursement_id: ''),
        edit_steps_disbursement_cost_path(id: application.id, disbursement_id: ''),
        edit_steps_disbursements_path(id: application.id),
      ].any? do |path|
        application.navigation_stack.any? { |stack| stack.start_with?(path) }
      end
    end

    # TODO: is it possible to NOT have disbursements? do we need to flag this?
    def completed?
      application.disbursements.any? && application.disbursements.all? do |record|
        FORMS.all? { |form| super(record, form) }
      end
    end
  end
end
