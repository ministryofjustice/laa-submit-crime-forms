module Nsm
  module Steps
    class DisbursementsController < Nsm::Steps::BaseController
      before_action :set_default_table_sort_options, only: [:edit, :update]

      def edit
        disbursements = Sorters::DisbursementsSorter.call(
          current_application.disbursements.by_age, @sort_by, @sort_direction
        )
        @pagy, @disbursements = pagy_array(disbursements)

        @form_object = DisbursementsForm.build(
          current_application
        )

        @summary = CostSummary::Disbursements.new(current_application.disbursements, current_application)
      end

      def update
        disbursements = Sorters::DisbursementsSorter.call(
          current_application.disbursements.by_age, @sort_by, @sort_direction
        )
        @pagy, @disbursements = pagy_array(disbursements)
        @summary = CostSummary::Disbursements.new(current_application.disbursements, current_application)

        update_and_advance(DisbursementsForm, as: :disbursements)
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
    end
  end
end
