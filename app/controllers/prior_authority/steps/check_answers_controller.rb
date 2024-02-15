module PriorAuthority
  module Steps
    class CheckAnswersController < PriorAuthority::Steps::BaseController
      # TODO: This is a placeholder to show how the before_action would be implemented
      # expect to repeat this before form submission as well.
      #
      # before_action :check_complete?

      def edit
        @application = current_application
        @application.update!(navigation_stack: stack_with_step_moved_to_end)

        @report = CheckAnswers::Report.new(@application)
      end

      # TODO: CRM457-1132 check answers confirmation form
      def update
        # update_and_advance(CheckAnswersForm, as:, after_commit_redirect_path:)
      end

      private

      def stack_with_step_moved_to_end
        stack_with_step_moved_to_end = @application.navigation_stack.delete_if { |step| step == request.fullpath }
        stack_with_step_moved_to_end << request.fullpath
        stack_with_step_moved_to_end
      end

      # def check_complete?
      #   return if PriorAuthority::Tasks::CheckAnswers.new(application: current_application).status.complete?

      #   redirect_to prior_authority_steps_start_page_path(application)
      # end
    end
  end
end
