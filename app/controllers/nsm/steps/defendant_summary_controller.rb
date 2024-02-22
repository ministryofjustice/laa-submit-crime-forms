module Nsm
  module Steps
    class DefendantSummaryController < Nsm::Steps::BaseController
      def edit
        @main_defendant, *@additional_defendants = current_application.defendants
        @form_object = ::Steps::AddAnotherForm.build(
          current_application
        )
      end

      def update
        @main_defendant, *@additional_defendants = current_application.defendants
        update_and_advance(::Steps::AddAnotherForm, as: :defendant_summary)
      end

      private

      def decision_tree_class
        Decisions::NsmDecisionTree
      end

      def additional_permitted_params
        [:add_another]
      end
    end
  end
end
