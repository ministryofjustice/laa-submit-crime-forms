module CheckAnswers
  class ClaimJustificationCard
    attr_reader :reason_for_claim

    def initialize(claim)
      @reason_for_claim_form = Steps::ReasonForClaimForm.build(claim)
    end

    def route_path
      'reason_for_claim'
    end

    def title
      I18n.t('steps.check_answers.groups.about_claim.claim_justification.title')
    end
  end
end
