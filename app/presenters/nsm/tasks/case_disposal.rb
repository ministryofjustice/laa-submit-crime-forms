module Nsm
  module Tasks
    class CaseDisposal < Base
      PREVIOUS_TASKS = HearingDetails
      FORM = Nsm::Steps::CaseDisposalForm

      def path
        edit_nsm_steps_case_disposal_path(application)
      end

      def not_applicable?
        !FeatureFlags.youth_court_fee.enabled?
      end
    end
  end
end
