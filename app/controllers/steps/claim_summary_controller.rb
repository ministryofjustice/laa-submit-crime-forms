module Steps
  class ClaimSummaryController < Steps::BaseStepController
    def edit
      @claims={ preparation: 52.15, advocacy: 65.42, attendance_with_counsel: 35.68,
        attendance_without_counsel: 35.68, travel: 27.6, waiting: 27.6}
      @work_items_by_date = current_application.work_items.group_by(&:completed_on)
      @form_object = AddAnotherForm.build(
        current_application
      )
    end

    def update
      @work_items_by_date = current_application.work_items.group_by(&:completed_on)
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
