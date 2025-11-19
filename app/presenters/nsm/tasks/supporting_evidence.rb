# frozen_string_literal: true

module Nsm
  module Tasks
    class SupportingEvidence < Base
      PREVIOUS_TASKS = OtherInfo
      FORM = Nsm::Steps::SupportingEvidenceForm

      def path
        edit_nsm_steps_supporting_evidence_path(application)
      end

      def complete?
        return false if application.gdpr_documents_deleted

        application.supporting_evidence.present?
      end
    end
  end
end
