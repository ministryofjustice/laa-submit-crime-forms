module Tasks
  class ReasonForClaim < BaseTask
    def path
      edit_steps_reason_for_claim_path
    end

    def not_applicable?
      false
    end

    def can_start?
      fulfilled?(DefendantDetails)
    end

    def completed?
      application.reasons_for_claim.any? &&
        Steps::ReasonForClaimForm.new(application:).valid?
    end
  end
end
