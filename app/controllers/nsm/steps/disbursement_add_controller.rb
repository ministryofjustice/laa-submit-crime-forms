module Nsm
  module Steps
    class DisbursementAddController < Nsm::Steps::BaseController
      def edit
        @form_object = DisbursementAddForm.build(
          current_application
        )
      end

      def update
        update_and_advance(DisbursementAddForm, as: :disbursement_add)
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
