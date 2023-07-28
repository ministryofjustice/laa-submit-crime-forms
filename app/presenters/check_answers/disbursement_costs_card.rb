# frozen_string_literal: true

module CheckAnswers
  class DisbursementCostsCard < CostSummary::Disbursements
    attr_reader :section

    def title(**_opt)
      I18n.t('steps.check_answers.groups.about_claim.disbursements.title')
    end

    def initialize(claim)
      super(claim.disbursements, claim)
      @section = 'disbursements'
    end
  end
end
