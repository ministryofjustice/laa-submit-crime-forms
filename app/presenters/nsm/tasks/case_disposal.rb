module Nsm
  module Tasks
    class CaseDisposal < Base
      PREVIOUS_TASKS = HearingDetails
      FORM = Nsm::Steps::CaseDisposalForm

      def path
        edit_nsm_steps_case_disposal_path(application)
      end
    end
  end
end
