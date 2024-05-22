# frozen_string_literal: true

module Nsm
  module Steps
    class ViewClaimController < Nsm::Steps::BaseController
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
        @pagy, @work_items = pagy(current_application.work_items)
      end

      def letters_and_calls
        @claim = current_application
      end

      def disbursements
        @pagy, @disbursements = pagy(current_application.disbursements.by_age)
      end
    end
  end
end
