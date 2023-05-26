module Tasks
  class ReasonForClaim < BaseTask
    def path
      edit_steps_reason_for_claim_path(application)
    end

    def not_applicable?
      false
    end

    def can_start?
      fulfilled?(Defendants)
    end

    def completed?
      application.reasons_for_claim.any? &&
        Steps::ReasonForClaimForm.build(application).valid?
    end
  end
end
