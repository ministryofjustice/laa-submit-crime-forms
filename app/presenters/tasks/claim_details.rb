module Tasks
  class ClaimDetails < BaseTask
    def path
      edit_steps_claim_details_path(application)
    end

    def not_applicable?
      false
    end

    def can_start?
      fulfilled?(ReasonForClaim)
    end

    def completed?
      Steps::ClaimDetailsForm.build(application).valid?
    end
  end
end
