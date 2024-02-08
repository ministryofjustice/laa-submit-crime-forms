module PriorAuthority
  module Tasks
    class CheckAnswers < ::Tasks::Generic
      PREVIOUS_TASKS = Ufn

      def path
        prior_authority_steps_check_answers_path(application)
      end

      # TODO: completed once user has moved to the next page?? remove nocov once we have a next page
      # :nocov:
      def completed?
        application.navigation_stack[0..-2].include?(path)
      end
      # :nocov:
    end
  end
end
