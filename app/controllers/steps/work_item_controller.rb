module Steps
  class WorkItemController < Steps::BaseStepController
    before_action :ensure_work_item

    def edit
      @form_object = WorkItemForm.build(
        work_item,
        application: current_application,
      )
    end

    def update
      update_and_advance(WorkItemForm, as: :work_item, record: work_item)
    end

    private

    def decision_tree_class
      Decisions::SimpleDecisionTree
    end

    def work_item
      @work_item ||=
        if params[:work_item_id] == StartPage::CREATE_FIRST
          current_application.work_items.create
        else
          current_application.work_items.find_by(id: params[:work_item_id])
        end
    end

    def ensure_work_item
      work_item || redirect_to(edit_steps_work_items_path(current_application))
    end
  end
end
