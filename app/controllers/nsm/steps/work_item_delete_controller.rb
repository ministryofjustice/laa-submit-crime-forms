module Nsm
  module Steps
    class WorkItemDeleteController < Nsm::Steps::BaseController
      before_action :ensure_work_item

      def edit
        @form_object = ::Steps::DeleteForm.build(
          work_item,
          application: current_application,
        )
      end

      def update
        update_and_advance(::Steps::DeleteForm, as: :work_item_delete, record: work_item, flash: flash_msg)
      end

      private

      def decision_tree_class
        Decisions::NsmDecisionTree
      end

      def work_item
        @work_item ||= begin
          work_item_id = params[:work_item_id] || params.dig(:steps_delete_form, :id)
          current_application.work_items.find_by(id: work_item_id)
        end
      end

      def flash_msg
        { success: t('.edit.deleted_flash') }
      end

      def ensure_work_item
        work_item || redirect_to(edit_nsm_steps_work_items_path(current_application))
      end

      def skip_stack
        true
      end
    end
  end
end
