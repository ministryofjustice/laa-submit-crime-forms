module Tasks
  class ClaimType < Generic
    FORM = Steps::ClaimTypeForm

    def path
      edit_steps_claim_type_path(application)
    end

    def in_progress?
      true
    end

    def can_start?
      true
    end
  end
end
