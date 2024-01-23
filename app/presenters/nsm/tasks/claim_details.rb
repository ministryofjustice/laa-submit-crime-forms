module Tasks
  class ClaimDetails < Generic
    FORM = Steps::ClaimDetailsForm

    def path
      edit_steps_claim_details_path(application)
    end

    def not_applicable?
      false
    end

    def can_start?
      fulfilled?(ReasonForClaim)
    end
  end
end
