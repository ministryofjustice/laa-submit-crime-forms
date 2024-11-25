module Nsm
  module Tasks
    class CaseOutcome < Base
      PREVIOUS_TASKS = HearingDetails
      FORM = Nsm::Steps::CaseOutcomeForm

      def path
        edit_nsm_steps_case_outcome_path(application)
      end

      def not_applicable?
        application.before_youth_court_cutoff?
      end
    end
  end
end
