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
        update_and_advance(DisbursementCostForm,
                           as: :disbursement_cost,
                           record: disbursement,
                           flash: build_flash)
      end

      private

      def decision_tree_class
        Decisions::DecisionTree
      end

      def disbursement
        @disbursement ||= current_application.disbursements.find_by(id: params[:disbursement_id])
      end

      def ensure_disbursement
        disbursement || redirect_to(edit_nsm_steps_work_items_path(current_application))
      end

      def additional_permitted_params
        [:apply_vat, :add_another]
      end

      def new_record?
        disbursement.total_cost_pre_vat.nil? && disbursement.miles.nil?
      end

      def build_flash
        if new_record?
          if params.dig(:nsm_steps_disbursement_cost_form, :add_another) == YesNoAnswer::YES.to_s
            count = current_application.disbursements.count
            { success: t('.added', count: count, disbursements: t('.disbursement').pluralize(count)) }
          else
            {}
          end
        else
          { success: t('.updated') }
        end
      end
    end
  end
end
