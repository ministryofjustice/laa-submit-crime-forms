module CheckAnswers
  class EvidenceUploadsCard < Base
    def initialize(claim)
    
    end
    
    def title
      I18n.t('steps.check_answers.groups.supporting_evidence.evidence_upload.title')
    end
  end
end
