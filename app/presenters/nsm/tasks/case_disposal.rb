module Nsm
  module Tasks
    class CaseDisposal < Generic
      PREVIOUS_TASK = HearingDetails
      FORM = Nsm::Steps::CaseDisposalForm

      def path
        edit_nsm_steps_case_disposal_path(application)
      end
    end
  end
end
