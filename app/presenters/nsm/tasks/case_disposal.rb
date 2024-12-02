module Nsm
  module Tasks
    class CaseDisposal < Base
      PREVIOUS_TASKS = HearingDetails

      def path
        if application.nsm? && application.before_youth_court_cutoff?
          edit_nsm_steps_case_disposal_path(application)
        else
          edit_nsm_steps_case_category_path(application)
        end
      end

      def form
        if application.nsm? && application.can_claim_youth_court?
          Steps::CaseCategoryForm
        else
          Steps::CaseDisposalForm
        end
      end
    end
  end
end
