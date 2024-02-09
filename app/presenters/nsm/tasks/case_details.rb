module Nsm
  module Tasks
    class CaseDetails < ::Tasks::Generic
      PREVIOUS_TASKS = Defendants
      FORM = Nsm::Steps::CaseDetailsForm

      def path
        edit_nsm_steps_case_details_path(application)
      end
    end
  end
end
