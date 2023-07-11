module CheckAnswers
  class DisbursementCostsCard < Base
    def initialize(claim)
    
    end
    
    def title
      I18n.t('steps.check_answers.groups.about_claim.disbursement_costs.title')
    end
  end
end
