module Tasks
  class PriorAuthorityCaseContact < Tasks::Generic
    PREVIOUS_TASK = PriorAuthorityUfn
    FORM = ::PriorAuthority::Steps::CaseContactForm

    def path
      edit_prior_authority_steps_case_contact_path(application)
    end
  end
end
