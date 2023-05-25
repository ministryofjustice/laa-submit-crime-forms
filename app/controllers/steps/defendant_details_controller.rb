module Steps
  class DefendantDetailsController < Steps::BaseStepController
    def edit
      @form_object = DefendantDetailsForm.build(
        defendant,
        application: current_application,
      )
    end

    def update
      update_and_advance(DefendantDetailsForm, as: :defendant_details, record: defendant)
    end

    private

    def decision_tree_class
      Decisions::SimpleDecisionTree
    end

    def defendant
      if params[:defendant_id].blank?
        current_application.defendants.find_or_create_by!(position: 1, main: true)
      else
        current_application.defendants.find_by!(id: params[:defendant_id])
      end
    end
  end
end
