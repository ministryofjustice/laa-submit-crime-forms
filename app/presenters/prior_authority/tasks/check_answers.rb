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

      def completed?
        application.status == PriorAuthorityApplication.statuses[:submitted]
      end
    end
  end
end
