module Nsm
  module Steps
    class ClaimConfirmationController < ::Steps::BaseStepController
      def show
        @laa_reference = current_application.laa_reference
      end
    end
  end
end
