module Nsm
  module Steps
    class DisbursementDeleteController < Nsm::Steps::BaseController
      before_action :ensure_disbursement

      def edit
        @form_object = ::Steps::DeleteForm.build(
          disbursement,
          application: current_application,
        )
      end

      def update
        update_and_advance(::Steps::DeleteForm, as: :disbursement_delete, record: disbursement, flash: flash_msg)
      end

      private

      def disbursement
        if instance_variable_defined?(:@disbursement)
          @disbursement
        else
          @disbursement = current_application.disbursements.find_by(id: params[:disbursement_id])
        end
      end

      def flash_msg
        { success: t('.edit.deleted_flash') }
      end

      def ensure_disbursement
        disbursement || redirect_to(edit_nsm_steps_disbursements_path(current_application))
      end

      def do_not_add_to_viewed_steps
        true
      end
    end
  end
end
