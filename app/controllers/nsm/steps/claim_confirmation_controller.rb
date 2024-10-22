module Nsm
  module Steps
    class ClaimConfirmationController < Nsm::Steps::BaseController
      def show
        @laa_reference = current_application.laa_reference
      end

      def step_valid?
        current_application.submitted? || current_application.provider_updated?
      end
    end
  end
end
