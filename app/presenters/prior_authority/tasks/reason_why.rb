module PriorAuthority
  module Tasks
    class ReasonWhy < Base
      PREVIOUS_TASK = PriorAuthority::Tasks::ClientDetail
      FORM = ::PriorAuthority::Steps::ReasonWhyForm

      def path
        edit_prior_authority_steps_reason_why_path(application)
      end
    end
  end
end
