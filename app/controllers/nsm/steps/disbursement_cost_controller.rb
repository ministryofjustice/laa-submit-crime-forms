module Nsm
  module Steps
    class DisbursementCostController < Nsm::Steps::BaseController
      before_action :ensure_disbursement

      def edit
        @form_object = DisbursementCostForm.build(
          disbursement,
          application: current_application,
        )
      end

      def update
        update_and_advance(DisbursementCostForm, as: :disbursement_cost, record: disbursement)
      end

      private

      def decision_tree_class
        Decisions::NsmDecisionTree
      end

      def disbursement
        @disbursement ||= current_application.disbursements.find_by(id: params[:disbursement_id])
      end

      def ensure_disbursement
        disbursement || redirect_to(edit_nsm_steps_work_items_path(current_application))
      end

      def additional_permitted_params
        [:apply_vat]
      end
    end
  end
end
