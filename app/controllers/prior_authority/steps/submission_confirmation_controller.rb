module PriorAuthority
  module Steps
    class SubmissionConfirmationController < BaseController
      skip_before_action :update_viewed_steps, :prune_viewed_steps
      def show
        @laa_reference = current_application.laa_reference
      end

      private

      def step_valid?
        # By the time a provider has submitted their application and been redirected here it may already
        # have been autogranted, but we still want them to see this screen, which is why auto_grant is
        # included here.
        current_application.submitted? || current_application.provider_updated? || current_application.auto_grant?
      end

      def current_application
        @current_application ||= AppStoreDetailService.prior_authority(params[:application_id], current_provider)
      end
    end
  end
end
