module Nsm
  module Steps
    class DisbursementsController < Nsm::Steps::BaseController
      def edit
        @disbursements = current_application.disbursements.by_age
        @form_object = DisbursementsForm.build(
          current_application
        )
      end

      def update
        @disbursements = current_application.disbursements.by_age
        update_and_advance(DisbursementsForm, as: :disbursements)
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
