module Steps
  class SolicitorDeclarationController < Steps::BaseStepController
    def edit
      @form_object = SolicitorDeclarationForm.build(
        current_application
      )
    end

    def update
      update_and_advance(SolicitorDeclarationForm, as: :solicitor_declaration)
    end

    private

    def decision_tree_class
      Decisions::SimpleDecisionTree
    end
  end
end
