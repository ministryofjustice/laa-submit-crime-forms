module Nsm
  module Tasks
    class ClaimType < Base
      def path
        edit_nsm_steps_claim_type_path(application)
      end

      def in_progress?
        true
      end

      def can_start?
        true
      end

      def completed?
        application.claim_type == ::ClaimType::BREACH_OF_INJUNCTION.to_s ||
          application.office_in_undesignated_area == false ||
          application.court_in_undesignated_area ||
          !application.transferred_from_undesignated_area.nil?
      end
    end
  end
end
