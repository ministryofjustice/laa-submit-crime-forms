module Steps
  class CheckAnswersController < Steps::BaseStepController
    def show; end

    private

    def decision_tree_class
      Decisions::SimpleDecisionTree
    end
  end
end
