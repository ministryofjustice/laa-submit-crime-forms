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
      @disbursement ||=
        if params[:disbursement_id] == StartPage::NEW_RECORD
          current_application.disbursements.build(id: StartPage::NEW_RECORD)
        else
          current_application.disbursements.find_by(id: params[:disbursement_id])
        end
    end

    def ensure_disbursement
      disbursement || redirect_to(edit_steps_disbursements_path(current_application))
    end
  end
end
