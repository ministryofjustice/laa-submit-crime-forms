# frozen_string_literal: true

module Nsm
  module Steps
    class ViewClaimController < Nsm::Steps::BaseController
      def show
        @report = CheckAnswers::ReadOnlyReport.new(current_application)
        @claim = current_application
        @section = params.fetch(:section, :overview).to_sym
      end

      def work_items
        @work_items = current_application.work_items.map do
          Nsm::Steps::WorkItemForm.build(_1, application: current_application)
        end
      end

      def letters_and_calls
        head :ok
      end

      def disbursements
        head :ok
      end
    end
  end
end
