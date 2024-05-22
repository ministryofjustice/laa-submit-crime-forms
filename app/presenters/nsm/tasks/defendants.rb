module Nsm
  module Tasks
    class Defendants < Base
      PREVIOUS_TASKS = FirmDetails
      FORM = Nsm::Steps::DefendantDetailsForm
      PREVIOUS_STEP_NAME = :firm_details

      def in_progress?
        [
          edit_nsm_steps_defendant_summary_path(application),
          edit_nsm_steps_defendant_details_path(id: application.id, defendant_id: '')
        ].any? do |path|
          application.navigation_stack.any? { |stack| stack.start_with?(path) }
        end
      end

      def path
        if application.defendants.none?
          edit_nsm_steps_defendant_details_path(id: application.id, defendant_id: StartPage::NEW_RECORD)
        else
          edit_nsm_steps_defendant_summary_path(application)
        end
      end

      def completed?
        application.defendants.any? && application.defendants.all? do |record|
          super(record)
        end
      end
    end
  end
end
