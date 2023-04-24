module Steps
  class ClaimReasonController < Steps::BaseStepController
    def edit
      @form_object = ClaimReasonForm.build(
        current_application
      )
    end

    def update
      update_and_advance(ClaimReasonForm, as: :claim_reason)
    end

    private

    def decision_tree_class
      Decisions::SimpleDecisionTree
    end
  end
end
