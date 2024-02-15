module PriorAuthority
  module Tasks
    class CheckAnswers < Base
      PREVIOUS_TASKS = [
        PriorAuthority::Tasks::Ufn,
        PriorAuthority::Tasks::CaseContact,
        PriorAuthority::Tasks::ClientDetail,
        PriorAuthority::Tasks::CaseAndHearingDetail,
        PriorAuthority::Tasks::PrimaryQuote,
        PriorAuthority::Tasks::AlternativeQuotes,
        PriorAuthority::Tasks::ReasonWhy,
      ].freeze

      def path
        edit_prior_authority_steps_check_answers_path
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
