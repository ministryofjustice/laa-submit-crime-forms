module Nsm
  module Steps
    class WorkItemsController < Nsm::Steps::BaseController
      before_action :set_default_table_sort_options

      def edit
        @items_incomplete_flash = build_items_incomplete_flash
        @summary = CostSummary::WorkItems.new(current_application.work_items, current_application)
        @pagy, @work_items = pagy_array(Sorters::WorkItemsSorter.call(current_application.work_items, @sort_by, @sort_direction))
        @form_object = WorkItemsForm.build(
          current_application
        )
      end

      def update
        @summary = CostSummary::WorkItems.new(current_application.work_items, current_application)
        @pagy, @work_items = pagy_array(Sorters::WorkItemsSorter.call(current_application.work_items, @sort_by, @sort_direction))
        update_and_advance(WorkItemsForm, as: :work_items)
      end

      private

      def additional_permitted_params
        [:add_another]
      end

      def set_default_table_sort_options
        default = 'date'
        @sort_by = params.fetch(:sort_by, default)
        @sort_direction = params.fetch(:sort_direction, 'ascending')
      end

      def incomplete_work_item_summary
        @incomplete_work_item_summary ||= IncompleteItems.new(current_application.work_items, current_application, :work_items,
                                                              self)
      end

      def build_items_incomplete_flash
        incomplete_work_item_summary.incomplete_items.blank? ? nil : { default: incomplete_work_item_summary.summary }
      end
    end
  end
end
