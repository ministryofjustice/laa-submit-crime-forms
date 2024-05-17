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
        @pagy, items = pagy(current_application.work_items)
        @work_items = items.map do |work_item|
          Nsm::Steps::WorkItemForm.build(work_item, application: current_application)
        end
      end

      def letters_and_calls
        @claim = current_application
      end

      def disbursements
        @pagy, items = pagy(current_application.disbursements.by_age)
        @disbursements = items.map do |disbursement|
          Nsm::Steps::DisbursementCostForm.build(disbursement, application: current_application)
        end
      end
    end
  end
end
