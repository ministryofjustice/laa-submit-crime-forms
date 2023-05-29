module Tasks
  class ClaimDetails < BaseTask
    def path
      edit_steps_claim_details_path(application)
    end

    def not_applicable?
      false
    end

    def can_start?
      fulfilled?(Defendants)
    end

    def completed?
      application.claim_details.any? &&
        Steps::ClaimDetails.build(application).valid?
    end
  end
end
