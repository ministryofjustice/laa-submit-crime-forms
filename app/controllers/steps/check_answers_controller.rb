module Steps
  class CheckAnswersController < Steps::BaseStepController
    def show
      @report = CheckAnswers::Report.new(current_application)
    end
  end
end
