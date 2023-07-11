module Tasks
  class CheckAnswers < Generic
    PREVIOUS_TASK = OtherInfo

    def path
      steps_check_answers_path(application)
    end
  end
end
