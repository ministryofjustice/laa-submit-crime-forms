module Steps
  class CheckAnswersController < Steps::BaseStepController
    def show
      @form_object = Steps::Shared::NoOpForm.build(
        current_application
      )
      @report = CheckAnswers::Report.new(current_application)
    end

    private

    def decision_tree_class
      Decisions::SimpleDecisionTree
    end
  end
end
