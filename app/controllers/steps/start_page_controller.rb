module Steps
  class StartPageController < Steps::BaseStepController
    def show
      @tasklist = StartPageTaskList.new(
        view_context, application: current_application
      )
      # passed in separately to current_application to
      # allow it to be wrapped in a presenter in the future
      @application = current_application
      render 'laa_multi_step_forms/task_list/show'
    end
  end
end
