# frozen_string_literal: true

module Nsm
  module Steps
    class ViewClaimController < ::Steps::BaseStepController
      def show
        @report = CheckAnswers::ReadOnlyReport.new(current_application)
      end
    end
  end
end
