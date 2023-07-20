module Tasks
  class CheckAnswers < Generic
    PREVIOUS_TASK = OtherInfo

    def path
      steps_check_answers_path(application)
    end

    # completed once user has moved to the next page
    def completed?
      application.navigation_stack[0..-2].include?(path)
    end
  end
end