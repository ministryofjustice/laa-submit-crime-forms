module Steps
  class DefendantDetailsController < Steps::BaseStepController
    before_action :ensure_defendant

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
      @defendant ||= begin
        defendant_id = params[:defendant_id] || params.dig(:steps_defendant_details_form, :id)
        if defendant_id.blank?
          current_application.defendants.find_or_create_by!(position: 1, main: true)
        else
          current_application.defendants.find_by(id: defendant_id)
        end
      end
    end

    def ensure_defendant
      defendant || redirect_to(edit_steps_defendant_summary_path(current_application))
    end
  end
end
