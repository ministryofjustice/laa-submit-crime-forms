module Nsm
  module Tasks
    class ClaimConfirmation < Generic
      PREVIOUS_TASK = SolicitorDeclaration

      def path
        nsm_steps_claim_confirmation_path(application)
      end
    end
  end
end
