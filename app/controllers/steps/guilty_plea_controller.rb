module Steps
  class GuiltyPleaController < Steps::BaseStepController
    def edit
      @form_object = GuiltyPleaForm.build(
        current_application
      )
    end

    def update
      update_and_advance(GuiltyPleaForm, as: :guilty_plea)
    end

    private

    def decision_tree_class
      Decisions::SimpleDecisionTree
    end
  end
end
