module Steps
  class StartPageController < Steps::BaseStepController
    def show
      return redirect_to steps_view_claim_path(current_application.id) if current_application.status == 'completed'

      @pre_tasklist = StartPage::PreTaskList.new(
        view_context, application: current_application, show_index: false
      )
      @tasklist = StartPage::TaskList.new(
        view_context, application: current_application
      )
      # passed in separately to current_application to
      # allow it to be wrapped in a presenter in the future
      @application = current_application
      render 'laa_multi_step_forms/task_list/show', locals: { header: -> { decision_step_header } }
    end
  end
end
