module Nsm
  module Tasks
    class ReasonForClaim < ::Tasks::Generic
      PREVIOUS_TASK = CaseDisposal
      FORM = Nsm::Steps::ReasonForClaimForm

      def path
        edit_nsm_steps_reason_for_claim_path(application)
      end

      def completed?
        application.reasons_for_claim.any? && super
      end
    end
  end
end
