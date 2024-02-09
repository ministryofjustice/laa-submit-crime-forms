module PriorAuthority
  module Tasks
    class PrimaryQuote < Base
      PREVIOUS_TASKS = [
        PriorAuthority::Tasks::Ufn,
        PriorAuthority::Tasks::CaseContact,
        PriorAuthority::Tasks::ClientDetail,
        PriorAuthority::Tasks::CaseAndHearingDetail,
      ].freeze

      FORM = ::PriorAuthority::Steps::PrimaryQuoteForm

      def path
        if completed?
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

      def completed?
        record && super && super(record, PriorAuthority::Steps::ServiceCostForm)
      end
    end
  end
end
