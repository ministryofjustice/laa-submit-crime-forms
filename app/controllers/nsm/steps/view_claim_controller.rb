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
        @work_items = current_application.work_items.map do |work_item|
          Nsm::Steps::WorkItemForm.build(work_item, application: current_application)
        end
      end

      def letters_and_calls
        @claim = current_application
      end

      def disbursements
        @disbursements = current_application.disbursements.by_age.map do |disbursement|
          Nsm::Steps::DisbursementCostForm.build(disbursement, application: current_application)
        end
      end
    end
  end
end
