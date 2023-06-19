module Steps
  class CostSummaryController < Steps::BaseStepController
    def show
      @report = CostSummary::Report.new(current_application)
    end
  end
end
