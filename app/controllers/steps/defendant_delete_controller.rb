module Steps
  class DefendantDeleteController < Steps::BaseStepController
    before_action :ensure_defendant
    def edit
      @form_object = DefendantDeleteForm.build(
        defendant,
        application: current_application,
      )
    end

    def update
      update_and_advance(DefendantDeleteForm, as: :defendant_delete, record: defendant, flash: flash_msg)
    end

    private

    def decision_tree_class
      Decisions::SimpleDecisionTree
    end

    def defendant
      current_application.defendants.find_by(position: 1, main: true)
    end


    def flash_msg
      { success: t('.edit.deleted_flash') }
    end

    def ensure_defendant
      defendant || redirect_to edit_steps_defendant_summary_path(current_application)
    end
  end
end
