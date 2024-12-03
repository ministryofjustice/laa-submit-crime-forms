module Nsm
  module Tasks
    class CheckAnswers < Base
      PREVIOUS_TASKS = SupportingEvidence

      def path
        nsm_steps_check_answers_path(application)
      end

      # completed once user has moved to the next page
      def completed?
        viewed_subsequent_step?
      end
    end
  end
end
