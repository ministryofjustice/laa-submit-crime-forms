module PriorAuthority
  module Tasks
    class PrimaryQuote < ::Tasks::Generic
      FORM = ::PriorAuthority::Steps::PrimaryQuoteForm

      def path
        if record && completed?(record, PriorAuthority::Steps::ServiceCostForm)
          prior_authority_steps_primary_quote_summary_path(application)
        else
          edit_prior_authority_steps_primary_quote_path(application)
        end
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
