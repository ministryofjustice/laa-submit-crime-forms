module Nsm
  module Steps
    class DefendantDeleteController < Nsm::Steps::BaseController
      before_action :ensure_defendant

      def edit
        @form_object = DefendantDeleteForm.build(
          defendant,
          application: current_application,
        )
      end

      def update
        update_and_advance(DefendantDeleteForm, as: :defendant_delete, record: defendant, flash: flash_msg)
      end

      private

      def defendant
        return @defendant if defined?(@defendant)

        @defendant = current_application.defendants.find_by(id: params[:defendant_id], main: false)
      end

      def flash_msg
        { success: t('.edit.deleted_flash') }
      end

      def ensure_defendant
        defendant || redirect_to(edit_nsm_steps_defendant_summary_path(current_application))
      end

      def do_not_add_to_viewed_steps
        true
      end
    end
  end
end
