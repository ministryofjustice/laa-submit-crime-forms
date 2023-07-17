module Steps
  class EqualityQuestionsController < Steps::BaseStepController
    def edit
      @form_object = EqualityQuestionsForm.build(
        current_application
      )
    end

    def update
      update_and_advance(EqualityQuestionsForm, as: :equality_questions)
    end

    private

    def decision_tree_class
      Decisions::SimpleDecisionTree
    end
  end
end
