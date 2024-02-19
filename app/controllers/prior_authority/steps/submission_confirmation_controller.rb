module PriorAuthority
  module Steps
    class SubmissionConfirmationController < BaseController
      def show
        @laa_reference = current_application.laa_reference
      end
    end
  end
end
