module Steps
  class FirmDetailsController < Steps::BaseStepController
    def edit
      @form_object = FirmDetailsForm.build(
        current_application
      )
    end

    def update
      update_and_advance(FirmDetailsForm, as: :firm_details)
    end

    private

    def decision_tree_class
      Decisions::SimpleDecisionTree
    end
  end
end
