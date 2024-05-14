module Nsm
  module Steps
    class StartPageController < Nsm::Steps::BaseController
      def show
        return redirect_to nsm_steps_view_claim_path(current_application.id) unless current_application.draft?

        @pre_tasklist = StartPage::PreTaskList.new(
          view_context, application: current_application, show_index: false
        )
        @tasklist = StartPage::TaskList.new(
          view_context, application: current_application
        )
        # passed in separately to current_application to
        # allow it to be wrapped in a presenter in the future
        @application = current_application
        render 'laa_multi_step_forms/task_list/show', locals: { app_type: 'claim' }
      end

      # we remove the check_answers entry from the list to reset the return
      # location after edits once the task list has been displayed
      def append_navigation_stack
        current_application.navigation_stack -= [
          "/prior-authority/applications/#{current_application.id}/steps/check_answers"
        ]

        super
      end
    end
  end
end
