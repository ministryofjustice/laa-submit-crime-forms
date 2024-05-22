module Nsm
  module Steps
    class DefendantSummaryController < Nsm::Steps::BaseController
      def edit
        @form_object = DefendantSummaryForm.build(
          current_application
        )
      end

      def update
        update_and_advance(DefendantSummaryForm, as: :defendant_summary)
      end

      private

      def decision_tree_class
        Decisions::DecisionTree
      end

      def additional_permitted_params
        [:add_another]
      end
    end
  end
end
