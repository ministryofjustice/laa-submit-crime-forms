module Nsm
  module Tasks
    class CostSummary < ::Tasks::Generic
      PREVIOUS_TASKS = Disbursements

      def can_start?
        case application.has_disbursements
        when YesNoAnswer::NO.to_s
          true
        when YesNoAnswer::YES.to_s
          super
        else
          false
        end
      end

      def path
        nsm_steps_cost_summary_path(application)
      end

      # completed once user has moved to the next page
      def completed?
        application.navigation_stack[0..-2].include?(path)
      end
    end
  end
end
