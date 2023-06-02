module Steps
  class WorkItemsController < Steps::BaseStepController
    def edit
      @work_items = current_application.work_items
      @form_object = AddAnotherForm.build(
        current_application
      )
    end

    def update
      @work_items = current_application.work_items
      update_and_advance(AddAnotherForm, as: :work_items)
    end

    private

    def decision_tree_class
      Decisions::SimpleDecisionTree
    end

    def additional_permitted_params
      [:add_another]
    end
  end
end
