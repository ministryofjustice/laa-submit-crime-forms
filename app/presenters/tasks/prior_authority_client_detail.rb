module Tasks
  class PriorAuthorityClientDetail < Tasks::Generic
    PREVIOUS_TASK = PriorAuthorityCaseContact
    FORM = ::PriorAuthority::Steps::ClientDetailForm

    def path
      edit_prior_authority_steps_client_detail_path(application)
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
