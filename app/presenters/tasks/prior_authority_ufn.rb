module Tasks
  class PriorAuthorityUfn < Tasks::Generic
    FORM = ::PriorAuthority::Steps::UfnForm

    def path
      edit_prior_authority_steps_ufn_path(application)
    end

    def not_applicable?
      false
    end

    def in_progress?
      true
    end

    def can_start?
      true
    end
  end
end
