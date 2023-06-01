module Steps
  class DefendantSummaryController < Steps::BaseStepController
    def edit
      @main_defendant, *@additional_defendants = current_application.defendants
      @form_object = AddAnotherForm.build(
        current_application
      )
    end

    def update
      @main_defendant, *@additional_defendants = current_application.defendants
      update_and_advance(AddAnotherForm, as: :defendant_summary)
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
