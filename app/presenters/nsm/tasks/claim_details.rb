module Nsm
  module Tasks
    class ClaimDetails < ::Tasks::Generic
      FORM = Nsm::Steps::ClaimDetailsForm

      def path
        edit_nsm_steps_claim_details_path(application)
      end

      def not_applicable?
        false
      end

      def can_start?
        fulfilled?(ReasonForClaim)
      end
    end
  end
end
