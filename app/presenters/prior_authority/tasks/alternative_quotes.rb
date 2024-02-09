module PriorAuthority
  module Tasks
    class AlternativeQuotes < Base
      FORM = ::PriorAuthority::Steps::AlternativeQuotes::OverviewForm
      PREVIOUS_TASK = PrimaryQuote

      def path
        prior_authority_steps_alternative_quotes_path(application)
      end

      def completed?
        super && all_alternative_quotes_valid?
      end

      def all_alternative_quotes_valid?
        application.alternative_quotes.all? do |quote|
          ::PriorAuthority::Steps::AlternativeQuotes::DetailForm.build(quote, application:).valid?
        end
      end
    end
  end
end
