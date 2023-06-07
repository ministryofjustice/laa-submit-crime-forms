module Steps
  class WorkItemDeleteController < Steps::BaseStepController
    before_action :ensure_work_item

    def edit
      @form_object = DeleteForm.build(
        work_item,
        application: current_application,
      )
    end

    def update
      update_and_advance(DeleteForm, as: :work_item_delete, record: work_item, flash: flash_msg)
    end

    private

    def decision_tree_class
      Decisions::SimpleDecisionTree
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
      work_item || redirect_to(edit_steps_work_items_path(current_application))
    end
  end
end
