module Tasks
  class CostSummary < Generic
    PREVIOUS_TASK = Disbursements

    def can_start?
      return false unless application.navigation_stack.include?(edit_steps_disbursement_add_path)

      if application.disbursements.none?
        true
      else
        super
      end
    end

    def path
      steps_cost_summary_path(application)
    end

    # completed once user has moved to the next page
    def completed?
      application.navigation_stack[0..-2].include?(path)
    end
  end
end
