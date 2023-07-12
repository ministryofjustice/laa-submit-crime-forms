module CheckAnswers
  class ClaimJustificationCard < Base
    def initialize(claim)
    
    end

    def route_path
      "reason_for_claim"
    end
    
    def title
      I18n.t('steps.check_answers.groups.about_claim.claim_justification.title')
    end
  end
end
