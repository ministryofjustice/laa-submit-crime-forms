module Tasks
  class ReasonForClaim < Generic
    PREVIOUS_TASK = HearingDetails
    FORM = Steps::ReasonForClaimForm

    def path
      edit_steps_reason_for_claim_path(application)
    end

    def completed?
      application.reasons_for_claim.any? && super
    end
  end
end
