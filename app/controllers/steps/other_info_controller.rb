module Steps
  class OtherInfoController < Steps::BaseStepController
    def edit
      @form_object = OtherInfoForm.build(
        current_application
      )
    end

    def update
      update_and_advance(OtherInfoForm, as: :other_info)
    end

    private

    def decision_tree_class
      Decisions::SimpleDecisionTree
    end
  end
end
