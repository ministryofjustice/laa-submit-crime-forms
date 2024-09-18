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
        claim_type_questions_completed? && office_code_questions_completed? && office_area_questions_completed?
      end

      def claim_type_questions_completed?
        application.claim_type.present?
      end

      def office_area_questions_completed?
        application.claim_type == ::ClaimType::BREACH_OF_INJUNCTION.to_s ||
          application.office_in_undesignated_area == false ||
          application.court_in_undesignated_area ||
          !application.transferred_to_undesignated_area.nil?
      end

      def office_code_questions_completed?
        application.office_code.present?
      end
    end
  end
end
