module Nsm
  module Tasks
    class ClaimConfirmation < ::Tasks::Generic
      PREVIOUS_TASKS = SolicitorDeclaration

      def path
        nsm_steps_claim_confirmation_path(application)
      end
    end
  end
end
