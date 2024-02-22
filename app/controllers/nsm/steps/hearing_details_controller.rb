module Nsm
  module Steps
    class HearingDetailsController < Nsm::Steps::BaseController
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
        Decisions::NsmDecisionTree
      end

      def additional_permitted_params
        [:court_suggestion]
      end
    end
  end
end
