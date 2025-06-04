module PriorAuthority
  module Steps
    class CheckAnswersController < BaseController
      before_action :check_complete?
      before_action :build_report

      def edit
        incomplete_tasks
        @form_object = CheckAnswersForm.build(
          current_application
        )
      end

      def update
        if incomplete_tasks.blank?
          update_and_advance(CheckAnswersForm, as:, after_commit_redirect_path:)
        else
          update_and_advance(CheckAnswersForm, as: as, save_and_refresh: true)
        end
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

      def incomplete_tasks
        @incomplete_tasks ||= PriorAuthority::ApplicationValidator.new(current_application).call
      end
    end
  end
end
