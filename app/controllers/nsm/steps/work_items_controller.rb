module Nsm
  module Steps
    class WorkItemsController < ::Steps::BaseStepController
      def edit
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
        Decisions::DecisionTree
      end

      def additional_permitted_params
        [:add_another]
      end
    end
  end
end
