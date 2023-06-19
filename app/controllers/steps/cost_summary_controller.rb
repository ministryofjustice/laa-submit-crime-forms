module Steps
  class CostSummaryController < Steps::BaseStepController
    def show
      @sections = CostSummary.new(current_application).sections
    end
  end
end
