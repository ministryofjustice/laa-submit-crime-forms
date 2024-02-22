module Nsm
  module Steps
    class DefendantDetailsController < Nsm::Steps::BaseController
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
        Decisions::NsmDecisionTree
      end

      def defendant
        @defendant ||=
          if params[:defendant_id] == StartPage::NEW_RECORD
            current_application.defendants.build(id: StartPage::NEW_RECORD)
          else
            current_application.defendants.find_by(id: params[:defendant_id])
          end
      end

      def ensure_defendant
        defendant || redirect_to(edit_nsm_steps_defendant_summary_path(current_application))
      end
    end
  end
end
