module PriorAuthority
  module Steps
    class StartPageController < BaseController
      def show
        redirect_to show_prior_authority_applications_path(current_application) unless current_application.draft?

        @pre_tasklist = StartPage::PreTaskList.new(
          view_context, application: current_application, show_index: false
        )

        @tasklist = start_page_tasklist
        # # passed in separately to current_application to
        # # allow it to be wrapped in a presenter in the future
        @application = current_application
        render 'laa_multi_step_forms/task_list/show', locals: { app_type: 'application' }
      end

      private

      def start_page_tasklist
        StartPage::TaskList.new(
          view_context, application: current_application
        )
      end

      def step_valid?
        current_application.draft? || current_application.pre_draft?
      end
    end
  end
end
