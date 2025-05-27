module PriorAuthority
  module Steps
    class CheckAnswersController < BaseController
      before_action :check_complete?
      before_action :build_report

      def edit
        incomplete_tasks_flash
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
        @report = CheckAnswers::Report.new(current_application)
      end

      def check_complete?
        return false if PriorAuthority::Tasks::CheckAnswers.new(application: current_application).can_start?

        redirect_to prior_authority_steps_start_page_path(current_application)
      end

      def step_valid?
        current_application.draft? || current_application.sent_back?
      end

      def incomplete_tasks_flash
        @incomplete_tasks_flash ||= PriorAuthority::ApplicationValidator.new(current_application).call
      end
    end
  end
end
