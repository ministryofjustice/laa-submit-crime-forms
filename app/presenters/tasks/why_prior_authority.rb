module Tasks

  class WhyPriorAuthority < Tasks::Generic
    PREVIOUS_TASK = PriorAuthorityClientDetail
    FORM = ::PriorAuthority::Steps::WhyPriorAuthorityForm

    def path
      edit_prior_authority_steps_why_prior_authority_path(application)
    end
  end
end
