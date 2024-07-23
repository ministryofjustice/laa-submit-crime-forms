# frozen_string_literal: true

module Nsm
  module Steps
    class ViewClaimController < Nsm::Steps::BaseController
      before_action :validate_prefix
      before_action :set_default_table_sort_options, only: %i[work_items disbursements]

      def show
        @report = CheckAnswers::ReadOnlyReport.new(current_application)
        @claim = current_application
        @section = params.fetch(:section, :overview).to_sym
      end

      def item
        @claim = current_application

        render report_params[:item_type]
      end

      def work_items
        @work_items = Sorters::WorkItemsSorter.call(current_application.work_items, @sort_by, @sort_direction)

        render prefixed_view_for('work_items')
      end

      def letters_and_calls
        @claim = current_application

        render prefixed_view_for('letters_and_calls')
      end

      def disbursements
        @disbursements = current_application.disbursements.by_age

        render prefixed_view_for('disbursements')
      end

      private

      def prefixed_view_for(item_type)
        "#{report_params[:prefix]}#{item_type}"
      end

      def report_params
        params.permit(
          :item_type,
          :prefix,
        )
      end

      def validate_prefix
        raise "Invalid prefix: #{params[:prefix]}" unless params[:prefix].in?(['allowed_', '', nil])
      end

      def set_default_table_sort_options
        default = 'line_item'
        @sort_by = params.fetch(:sort_by, default)
        @sort_direction = params.fetch(:sort_direction, 'ascending')
      end
    end
  end
end
