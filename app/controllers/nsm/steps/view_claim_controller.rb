# frozen_string_literal: true

module Nsm
  module Steps
    class ViewClaimController < Nsm::Steps::BaseController
      def show
        @claim = current_application
        @report = CheckAnswers::ReadOnlyReport.new(current_application)
      end
    end
  end
end
