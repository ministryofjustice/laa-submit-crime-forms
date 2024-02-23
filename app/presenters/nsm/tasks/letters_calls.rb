module Nsm
  module Tasks
    class LettersCalls < Base
      PREVIOUS_TASKS = WorkItems
      FORM = Nsm::Steps::LettersCallsForm

      def path
        edit_nsm_steps_letters_calls_path(application)
      end
    end
  end
end
