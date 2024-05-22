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

        render params[:item_type]
      end

      def work_items
        @work_items = current_application.work_items

        render "#{params[:prefix]}work_items"
      end

      def letters_and_calls
        @claim = current_application
      end

      def disbursements
        @pagy, @disbursements = pagy(current_application.disbursements.by_age)
      end

      private

      def validate_prefix
        raise "Invalid prefix: #{params[:prefix]}" unless params[:prefix].in?(['allowed_', '', nil])
      end
    end
  end
end
