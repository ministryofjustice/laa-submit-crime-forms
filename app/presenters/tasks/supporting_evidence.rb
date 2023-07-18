# frozen_string_literal: true
module Tasks
  class SupportingEvidence < Generic
    PREVIOUS_TASK = OtherInfo
    FORM = Steps::SupportingEvidenceForm

    def path
      edit_steps_supporting_evidence_path(application)
    end
  end
end
