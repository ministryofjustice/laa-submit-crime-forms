# frozen_string_literal: true

module Nsm
  module Tasks
    class SupportingEvidence < Base
      PREVIOUS_TASKS = OtherInfo
      FORM = Nsm::Steps::SupportingEvidenceForm

      def path
        edit_nsm_steps_supporting_evidence_path(application)
      end
    end
  end
end
