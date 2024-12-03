module Nsm
  module Tasks
    class CostSummary < Base
      PREVIOUS_TASKS = Disbursements

      def path
        nsm_steps_cost_summary_path(application)
      end

      # completed once user has moved to the next page
      def completed?
        viewed_subsequent_step?
      end
    end
  end
end
