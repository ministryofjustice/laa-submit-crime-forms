module Steps
  class EqualityController < Steps::BaseStepController
    def edit
      @form_object = AnswerEqualityForm.build(
        current_application
      )
    end

    def update
      update_and_advance(AnswerEqualityForm, as: :equality)
    end

    private

    def decision_tree_class
      Decisions::DecisionTree
    end

    def additional_permitted_params
      [:answer_equality]
    end
  end
end
