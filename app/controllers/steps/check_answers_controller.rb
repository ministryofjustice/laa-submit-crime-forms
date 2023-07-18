module Steps
  class CheckAnswersController < Steps::BaseStepController
    def show
      @report = CheckAnswers::Report.new(current_application)
    end

    private

    def decision_tree_class
      Decisions::SimpleDecisionTree
    end
  end
end
