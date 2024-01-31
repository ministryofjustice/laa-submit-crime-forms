module PriorAuthority
  module Tasks
    class PrimaryQuote < ::Tasks::Generic
      PREVIOUS_TASK = CaseAndHearingDetail
      FORM = ::PriorAuthority::Steps::PrimaryQuoteForm

      def path
        edit_prior_authority_steps_primary_quote_path(application)
      end

      def record
        application.primary_quote
      end
    end
  end
end
