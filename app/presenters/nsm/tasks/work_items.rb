module Nsm
  module Tasks
    class WorkItems < Base
      PREVIOUS_TASKS = ClaimDetails
      PREVIOUS_STEP_NAME = :claim_details
      FORM = Nsm::Steps::WorkItemForm

      def previously_visited?
        application.viewed_steps.intersect?(%w[work_items work_item])
      end

      def completed?
        application.work_items.any? && application.work_items.all?(&:complete?)
      end
    end
  end
end
