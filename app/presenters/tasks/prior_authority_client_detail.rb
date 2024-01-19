module Tasks
  class PriorAuthorityClientDetail < Tasks::Generic
    PREVIOUS_TASK = PriorAuthorityUfn
    FORM = ::PriorAuthority::Steps::ClientDetailForm

    def path
      edit_prior_authority_steps_client_detail_path(application)
    end
  end
end
