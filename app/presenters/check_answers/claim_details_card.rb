module CheckAnswers
  class ClaimDetailsCard
    attr_reader :claim_details_form

    def initialize(claim)
      @claim_details_form = Steps::ClaimDetailsForm.build(claim)
    end

    def route_path
      'claim_details'
    end

    def title
      I18n.t('steps.check_answers.groups.about_claim.claim_details.title')
    end
  end
end
