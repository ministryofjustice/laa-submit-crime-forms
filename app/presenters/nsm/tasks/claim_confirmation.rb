module Nsm
  module Tasks
    class ClaimConfirmation < Base
      PREVIOUS_TASKS = SolicitorDeclaration

      def path
        nsm_steps_claim_confirmation_path(application)
      end
    end
  end
end
