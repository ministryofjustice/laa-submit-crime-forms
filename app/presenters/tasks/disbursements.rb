module Tasks
  class Disbursements < Generic
    PREVIOUS_TASK = LettersCalls
    FORMS = [
      Steps::DisbursementTypeForm,
      Steps::DisbursementCostForm,
    ].freeze

    def path

      if application.disbursements.count.positive?
        edit_steps_disbursements_path(id: application)
      else
        edit_steps_disbursement_type_path(id: application, disbursement_id: StartPage::NEW_RECORD)
      end
    end

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
