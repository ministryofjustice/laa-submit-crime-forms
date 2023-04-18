module Steps
  class ClaimTypeController < Steps::BaseStepController
    def edit
      form_object = ClaimTypeForm.build(
        current_application
      )

      render locals: { form_object: }
    end

    def update
      update_and_advance(ClaimTypeForm, as: :claim_type)
    end

    private

    def decision_tree_class
      Desisions::SimpleDecisionTree
    end
  end
end
