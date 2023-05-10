module Steps
  class CaseDisposalController < Steps::BaseStepController
    def edit
      @form_object = CaseDisposalForm.build(
        current_application
      )
    end

    def update
      update_and_advance(CaseDisposalForm, as: :case_disposal)
    end

    private

    def decision_tree_class
      Decisions::SimpleDecisionTree
    end
  end
end
