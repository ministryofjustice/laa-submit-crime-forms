module PriorAuthority
  module Steps
    class SubmissionConfirmationController < BaseController
      def show
        @laa_reference = current_application.laa_reference
      end

      private

      def step_valid?
        current_application.submitted? || current_application.provider_updated?
      end
    end
  end
end
