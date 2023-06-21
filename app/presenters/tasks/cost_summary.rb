module Tasks
  class CostSummary < Generic
    PREVIOUS_TASK = LettersCalls

    def path
      steps_cost_summary_path(application)
    end

    # completed once user has moved to the next page
    def completed?
      application.navigation_stack[0..-2].include?(path)
    end
  end
end
