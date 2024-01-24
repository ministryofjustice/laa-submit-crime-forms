module PriorAuthority
  module Tasks
    class CaseAndHearingDetail < ::Tasks::Generic
      PREVIOUS_TASK = Ufn
      FORM = [::PriorAuthority::Steps::CaseDetailForm, ::PriorAuthority::Steps::HearingDetailForm].freeze

      def path
        edit_prior_authority_steps_case_detail_path(application)
      end
    end
  end
end
