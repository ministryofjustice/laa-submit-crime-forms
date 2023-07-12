module CheckAnswers
  class DisbursementCostsCard
    def initialize(claim)
    
    end

    def route_path
      "disbursements"
    end
    
    def title
      I18n.t('steps.check_answers.groups.about_claim.disbursement_costs.title')
    end
  end
end
