module PriorAuthority
  module Steps
    class SubmissionConfirmationController < BaseController
      def show
        @ufn = current_application.ufn
      end

      private

      def step_valid?
        # By the time a provider has submitted their application and been redirected here it may already
        # have been autogranted, but we still want them to see this screen, which is why auto_grant is
        # included here.
        current_application.submitted? || current_application.provider_updated? || current_application.auto_grant?
      end
    end
  end
end
