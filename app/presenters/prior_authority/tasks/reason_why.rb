module PriorAuthority
  module Tasks
    class ReasonWhy < Base
      PREVIOUS_TASKS = [
        PriorAuthority::Tasks::Ufn,
        PriorAuthority::Tasks::CaseContact,
        PriorAuthority::Tasks::ClientDetail,
        PriorAuthority::Tasks::CaseAndHearingDetail,
      ].freeze
      FORM = ::PriorAuthority::Steps::ReasonWhyForm

      def path
        edit_prior_authority_steps_reason_why_path(application)
      end
    end
  end
end
