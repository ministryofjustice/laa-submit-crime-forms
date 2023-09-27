# frozen_string_literal: true

module Steps
  class ViewClaimController < Steps::BaseStepController
    def show
      @report = CheckAnswers::Report.new(current_application, read_only: true)
    end
  end
end
