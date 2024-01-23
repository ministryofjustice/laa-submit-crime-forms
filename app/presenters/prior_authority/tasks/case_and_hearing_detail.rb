module PriorAuthority
  module Tasks
    class CaseAndHearingDetail < Tasks::Generic
      PREVIOUS_TASK = PriorAuthorityUfn
      FORM = [::PriorAuthority::Steps::CaseDetailForm].freeze

      def path
        edit_prior_authority_steps_case_detail_path(application)
      end
    end
  end
end
