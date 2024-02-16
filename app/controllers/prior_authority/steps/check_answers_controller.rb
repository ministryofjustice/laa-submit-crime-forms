module PriorAuthority
  module Steps
    class CheckAnswersController < PriorAuthority::Steps::BaseController
      # TODO: CRM457-1132 This is a placeholder to show how the before_action
      # would be implemented expect to repeat this before form submission as well.
      #
      # before_action :check_complete?

      before_action :build_report

      def edit
        @application.update!(navigation_stack: stack_with_step_moved_to_end)

        @form_object = CheckAnswersForm.build(
          current_application
        )
      end

      def update
        update_and_advance(CheckAnswersForm, as:, after_commit_redirect_path:)
      end

      private

      def as
        :check_answers
      end

      def build_report
        @application = current_application
        @report = CheckAnswers::Report.new(@application)
      end

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
