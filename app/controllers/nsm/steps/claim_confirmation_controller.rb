module Nsm
  module Steps
    class ClaimConfirmationController < Nsm::Steps::BaseController
      skip_before_action :update_viewed_steps, :prune_viewed_steps

      def show
        @placeholder_record_id = StartPage::NEW_RECORD
        @laa_reference = current_application.laa_reference
      end

      def step_valid?
        current_application.submitted? || current_application.provider_updated?
      end

      def current_application
        @current_application ||= AppStoreDetailService.nsm(params[:id], current_provider)
      end
    end
  end
end
