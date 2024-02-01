module PriorAuthority
  module Tasks
    class PrimaryQuote < ::Tasks::Generic
      FORM = ::PriorAuthority::Steps::PrimaryQuoteForm

      def path
        edit_prior_authority_steps_primary_quote_path(application)
      end

      def can_start?
        fulfilled?(CaseAndHearingDetail) && fulfilled?(ClientDetail)
      end

      def record
        application.primary_quote
      end
    end
  end
end
