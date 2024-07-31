module Nsm
  module Steps
    class DisbursementsController < Nsm::Steps::BaseController
      before_action :set_default_table_sort_options, only: :edit

      def edit
        @disbursements = Sorters::DisbursementsSorter.call(
          current_application.disbursements.by_age, @sort_by, @sort_direction
        )

        @form_object = DisbursementsForm.build(
          current_application
        )
      end

      def update
        @disbursements = current_application.disbursements.by_age
        update_and_advance(DisbursementsForm, as: :disbursements)
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
