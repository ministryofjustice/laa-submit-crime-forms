module CheckAnswers
  class DisbursementCostsCard
    attr_reader :disbursement_type_form

    def initialize(claim)
      @disbursement_type_form = Steps::DisbursementTypeForm.build(claim)
    end

    def route_path
      'disbursements'
    end

    def title
      I18n.t('steps.check_answers.groups.about_claim.disbursement_costs.title')
    end
  end
end
