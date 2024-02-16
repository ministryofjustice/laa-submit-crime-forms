module PriorAuthority
  module Steps
    class CheckAnswersController < BaseController
      before_action :check_completed, :build_report

      def edit
        current_application.update!(navigation_stack: stack_with_step_moved_to_end)

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

      def stack_with_step_moved_to_end
        stack_with_step_moved_to_end = current_application.navigation_stack.delete_if do |step|
          step == request.fullpath
        end
        stack_with_step_moved_to_end << request.fullpath
        stack_with_step_moved_to_end
      end

      def check_completed
        redirect_to prior_authority_steps_start_page_path(current_application) if answers_checked?
      end

      def answers_checked?
        PriorAuthority::Tasks::CheckAnswers.new(application: current_application).completed?
      end

      def build_report
        @report = CheckAnswers::Report.new(current_application)
      end
    end
  end
end
