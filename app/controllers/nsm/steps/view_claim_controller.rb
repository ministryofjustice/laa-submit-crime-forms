# frozen_string_literal: true

module Nsm
  module Steps
    class ViewClaimController < Nsm::Steps::BaseController
      before_action :set_section_and_scope
      before_action :set_default_table_sort_options

      def show
        render_show
      end

      def item
        render report_params[:item_type], locals: view_locals
      end

      def claimed_work_items
        @records = Sorters::WorkItemsSorter.call(app_store_record.work_items, @sort_by, @sort_direction)

        render_show
      end

      def adjusted_work_items
        @records = Sorters::WorkItemsSorter.call(app_store_record.work_items, @sort_by, @sort_direction)

        render_show
      end

      def claimed_letters_and_calls
        render_show
      end

      def adjusted_letters_and_calls
        render_show
      end

      def claimed_additional_fees
        render_show
      end

      def adjusted_additional_fees
        render_show
      end

      def claimed_disbursements
        @records = Sorters::DisbursementsSorter.call(
          app_store_record.disbursements.by_age, @sort_by, @sort_direction
        )

        render_show
      end

      def adjusted_disbursements
        @records = Sorters::DisbursementsSorter.call(
          app_store_record.disbursements.by_age, @sort_by, @sort_direction
        )

        render_show
      end

      def download
        pdf = PdfService.nsm(view_locals, request.url)

        send_data pdf,
                  filename: "#{current_application.laa_reference}.pdf",
                  type: 'application/pdf'
      end

      private

      def report_params
        params.permit(
          :id,
          :item_id,
          :item_type,
          :page,
          :sort_by,
          :sort_direction,
        )
      end

      def set_default_table_sort_options
        default = 'date'
        @sort_by = report_params.fetch(:sort_by, default)
        @sort_direction = report_params.fetch(:sort_direction, 'ascending')
      end

      def set_section_and_scope
        action = params[:action]
        @scope = :work_items
        @section = :overview

        case action
        when /^claimed_(.*)/
          @section = :claimed_costs
          @scope = ::Regexp.last_match(1).to_sym
        when /^adjusted_(.*)/
          @section = :adjustments
          @scope = ::Regexp.last_match(1).to_sym
        end
      end

      def render_show
        render :show, locals: view_locals
      end

      def view_locals
        { claim: app_store_record, report: report }
      end

      def app_store_record
        @app_store_record ||= AppStoreDetailService.nsm(params[:id], current_provider)
      end

      def report
        CheckAnswers::ReadOnlyReport.new(app_store_record, cost_summary_in_overview: false)
      end

      def check_step_valid
        redirect_to nsm_steps_start_page_path(current_application) unless step_valid?
      end

      def step_valid?
        !current_application.draft?
      end
    end
  end
end
