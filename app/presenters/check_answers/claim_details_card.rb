module CheckAnswers
  class ClaimDetailsCard < Base
    def initialize(claim)
    
    end

    def route_path
      "claim_details"
    end
    
    def title
      I18n.t('steps.check_answers.groups.about_claim.claim_details.title')
    end
  end
end
