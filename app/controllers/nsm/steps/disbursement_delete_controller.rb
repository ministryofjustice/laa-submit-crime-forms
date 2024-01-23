module Steps
  class DisbursementDeleteController < Steps::BaseStepController
    before_action :ensure_disbursement

    def edit
      @form_object = DeleteForm.build(
        disbursement,
        application: current_application,
      )
    end

    def update
      update_and_advance(DeleteForm, as: :disbursement_delete, record: disbursement, flash: flash_msg)
    end

    private

    def decision_tree_class
      Decisions::DecisionTree
    end

    def disbursement
      @disbursement ||= current_application.disbursements.find_by(id: params[:disbursement_id])
    end

    def flash_msg
      { success: t('.edit.deleted_flash') }
    end

    def ensure_disbursement
      disbursement || redirect_to(edit_steps_disbursements_path(current_application))
    end

    def skip_stack
      true
    end
  end
end
