module PriorAuthority
  module Steps
    class StartPageController < BaseController
      def show
        # TODO: requires more routes and logic so leaving for future iterations once a completed PA is available
        # return redirect_to steps_view_claim_path(current_application.id) unless current_application.draft?

        @pre_tasklist = StartPage::PreTaskList.new(
          view_context, application: current_application, show_index: false
        )

        @tasklist = StartPage::TaskList.new(
          view_context, application: current_application
        )
        # # passed in separately to current_application to
        # # allow it to be wrapped in a presenter in the future
        @application = current_application
        render 'laa_multi_step_forms/task_list/show', locals: { header: lambda {
                                                                          decision_step_header
                                                                        }, app_type: 'application' }
      end
    end
  end
end
