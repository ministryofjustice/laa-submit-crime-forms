module Nsm
  module Steps
    class ClaimConfirmationController < Nsm::Steps::BaseController
      def show
        @laa_reference = current_application.laa_reference
      end
    end
  end
end
