module Nsm
  module Tasks
    class ClaimType < ::Tasks::Generic
      FORM = Nsm::Steps::ClaimTypeForm

      def path
        edit_nsm_steps_claim_type_path(application)
      end

      def in_progress?
        true
      end

      def can_start?
        true
      end
    end
  end
end
