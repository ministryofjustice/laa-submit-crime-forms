# frozen_string_literal: true

module Nsm
  module Steps
    class ViewClaimController < Nsm::Steps::BaseController
      before_action :validate_prefix

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
        @work_items = current_application.work_items

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
    end
  end
end
