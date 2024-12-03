module Nsm
  module Tasks
    class CaseDisposal < Base
      PREVIOUS_TASKS = HearingDetails

      def path
        if application.before_youth_court_cutoff?
          edit_nsm_steps_case_disposal_path(application)
        else
          edit_nsm_steps_case_category_path(application)
        end
      end

      def form
        if application.before_youth_court_cutoff?
          Steps::CaseDisposalForm
        else
          Steps::CaseCategoryForm
        end
      end

      def completed?
        if application.can_access_youth_court_flow?
          plea_details_populated? && !application.include_youth_court_fee.nil?
        else
          plea_details_populated?
        end
      end

      private

      def plea_details_populated?
        application.plea.present? && application.plea_category.present?
      end
    end
  end
end
