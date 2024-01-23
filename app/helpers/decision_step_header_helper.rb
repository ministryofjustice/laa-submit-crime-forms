module DecisionStepHeaderHelper
  def decision_step_header(path: nil, record: nil)
    render partial: 'layouts/step_header', locals: {
      path: path || previous_decision_step_path(record:)
    }
  end

  def previous_decision_step_path(record:)
    form = Nsm::Steps::BaseFormObject.new(application: current_application, record: record)

    Decisions::BackDecisionTree.new(
      form,
      as: request.path_parameters[:controller]
    ).destination
  end
end
