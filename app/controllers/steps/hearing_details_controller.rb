module Steps
  class HearingDetailsController < Steps::BaseStepController
    def edit
      @form_object = HearingDetailsForm.build(
        current_application
      )
    end

    def update
      update_and_advance(HearingDetailsForm, as: :hearing_details)
    end

    private

    def decision_tree_class
      Decisions::SimpleDecisionTree
    end

    def additional_permitted_params
      [:court_suggestion]
    end
  end
end
