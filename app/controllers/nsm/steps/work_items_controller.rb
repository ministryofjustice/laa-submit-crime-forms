module Nsm
  module Steps
    class WorkItemsController < Nsm::Steps::BaseController
      before_action :set_default_table_sort_options

      def edit
        @work_items = Sorters::WorkItemsSorter.call(current_application.work_items, @sort_by, @sort_direction)
        @form_object = WorkItemsForm.build(
          current_application
        )
      end

      def update
        @work_items = Sorters::WorkItemsSorter.call(current_application.work_items, @sort_by, @sort_direction)
        update_and_advance(WorkItemsForm, as: :work_items)
      end

      private

      def decision_tree_class
        Decisions::DecisionTree
      end

      def additional_permitted_params
        [:add_another]
      end

      def set_default_table_sort_options
        default = 'line_item'
        @sort_by = params.fetch(:sort_by, default)
        @sort_direction = params.fetch(:sort_direction, 'ascending')
      end
    end
  end
end
