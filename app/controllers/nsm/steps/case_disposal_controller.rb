module Nsm
  module Steps
    class CaseDisposalController < Nsm::Steps::BaseController
      def edit
        @form_object = CaseDisposalForm.build(
          current_application
        )
      end

      def update
        update_and_advance(CaseDisposalForm, as: :case_disposal)
      end

      private

      def decision_tree_class
        Decisions::NsmDecisionTree
      end
    end
  end
end
