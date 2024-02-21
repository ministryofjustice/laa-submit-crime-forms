# frozen_string_literal: true

module PriorAuthority
  module CheckAnswers
    class AlternativeQuotesCard < Base
      attr_reader :application

      def initialize(application)
        @group = 'about_case'
        @section = 'alternative_quotes'
        @application = application
        super()
      end

      def row_data
        base_rows
      end

      def base_rows
        [
          *alternative_quote_summaries,
        ]
      end

      private

      def alternative_quote_summaries
        if alternative_quotes.present?
          alternative_quote_collection
        else
          no_alternative_quotes
        end
      end

      def alternative_quote_collection
        alternative_quotes.each_with_object([]).with_index do |(quote, memo), idx|
          memo << {
            head_key: 'quote_summary',
            head_opts: { count: idx + 1 },
            text: alternative_quote_summary_html(quote),
          }
          memo
        end
      end

      def no_alternative_quotes
        [
          {
            head_key: 'no_alternatve_quotes',
            text: application.no_alternative_quote_reason,
          }
        ]
      end

      def alternative_quotes
        @alternative_quotes ||= application.alternative_quotes
      end

      def alternative_quote_summary_html(quote)
        form = alternative_quote_form(quote)

        alternative_quote_summary_html = [
          quote.contact_full_name,
          quote.document&.file_name,
          NumberTo.pounds(form.total_cost)
        ].compact.join('<br>')

        sanitize(alternative_quote_summary_html, tags: %w[br])
      end

      def alternative_quote_form(quote)
        PriorAuthority::Steps::AlternativeQuotes::DetailForm.build(quote, application:)
      end
    end
  end
end
