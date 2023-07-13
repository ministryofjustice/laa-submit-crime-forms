module Steps
  class DisbursementsController < Steps::BaseStepController
    def edit
      @disbursements_by_date = current_application.disbursements.by_age.group_by(&:disbursement_date)
      @form_object = AddAnotherForm.build(
        current_application
      )
    end

    def update
      @disbursements_by_date = current_application.disbursements.by_age.group_by(&:disbursement_date)
      update_and_advance(AddAnotherForm, as: :disbursements)
    end

    private

    def decision_tree_class
      Decisions::SimpleDecisionTree
    end

    def additional_permitted_params
      [:add_another]
    end
  end
end
