module Steps
  class StartPageController < Steps::BaseStepController
    def show
      @pre_tasklist = StartPage::PreTaskList.new(
        view_context, application: current_application, show_index: false
      )
      @tasklist = StartPage::TaskList.new(
        view_context, application: current_application
      )
      # passed in separately to current_application to
      # allow it to be wrapped in a presenter in the future
      @application = current_application
      render 'laa_multi_step_forms/task_list/show'
    end

    private

    # We override this method as returning to this page shouldn't reset navigation history
    def update_navigation_stack
      return if current_application.navigation_stack.include?(request.fullpath)

      current_application.navigation_stack << request.fullpath
      current_application.save!(touch: false)
    end
  end
end
