module Tasks
  class LettersCalls < Generic
    PREVIOUS_TASK = ReasonForClaim
    FORM = Steps::LettersCallsForm

    def path
      edit_steps_letters_calls_path(application)
    end
  end
end
