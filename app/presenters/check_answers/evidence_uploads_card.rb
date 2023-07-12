module CheckAnswers
  class EvidenceUploadsCard < Base
    def initialize(claim); end

    # TO DO: This should go to the evidence uploads page but it's not made yet
    def route_path
      'firm_details'
    end

    def title
      I18n.t('steps.check_answers.groups.supporting_evidence.evidence_upload.title')
    end
  end
end
