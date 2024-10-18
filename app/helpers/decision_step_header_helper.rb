module DecisionStepHeaderHelper
  def decision_step_header(path: nil, record: nil)
    render partial: 'layouts/step_header', locals: {
      path: path || previous_decision_step_path(record:)
    }
  end

  def previous_decision_step_path(record:)
    form = Steps::BaseFormObject.new(application: current_application, record: record)
    return { controller: :check_answers, action: :edit } if params[:return_to] == 'check_answers'

    Decisions::BackDecisionTree.new(
      form,
      as: request.path_parameters[:controller]
    ).destination
  end
end
