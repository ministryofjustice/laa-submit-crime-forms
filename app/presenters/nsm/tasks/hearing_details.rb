module Nsm
  module Tasks
    class HearingDetails < Base
      PREVIOUS_TASKS = CaseDetails
      FORM = Nsm::Steps::HearingDetailsForm

      def path
        edit_nsm_steps_hearing_details_path(application)
      end
    end
  end
end
