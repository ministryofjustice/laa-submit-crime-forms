
module Steps
  class DisbursementTypeController < Steps::BaseStepController
    before_action :ensure_disbursement

    def edit
      @form_object = DisbursementTypeForm.build(
        disbursement,
        application: current_application,
      )
    end

    def update
      update_and_advance(DisbursementTypeForm, as: :disbursement_type, record: disbursement)
    end

    private

    def decision_tree_class
      Decisions::SimpleDecisionTree
    end

    def disbursement
      @disbursement ||= begin
        disbursement_id = params[:disbursement_id]
        current_application.disbursements.find_by(id: disbursement_id)
      end
    end

    def ensure_disbursement
      disbursement || redirect_to(edit_steps_work_items_path(current_application))
    end
  end
end
