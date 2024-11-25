module Nsm
  module Tasks
    class CaseCategory < Base
      PREVIOUS_TASKS = CaseOutcome
      FORM = Nsm::Steps::CaseCategoryForm

      def path
        edit_nsm_steps_case_category_path(application)
      end

      def not_applicable?
        application.before_youth_court_cutoff?
      end
    end
  end
end
