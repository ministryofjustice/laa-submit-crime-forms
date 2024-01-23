# frozen_string_literal: true

module Steps
  class ViewClaimController < Steps::BaseStepController
    def show
      @report = CheckAnswers::ReadOnlyReport.new(current_application)
    end
  end
end
