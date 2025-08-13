# frozen_string_literal: true

module PriorAuthority
  module CheckAnswers
    class AlternativeQuotesCard < Base
      attr_reader :application

      def initialize(application, verbose: false)
        @group = 'about_case'
        @section = 'alternative_quotes'
        @application = application
        @verbose = verbose
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

      def template
        'prior_authority/steps/check_answers/alternative_quotes' if @verbose && alternative_quotes.present?
      end

      def alternative_quote_forms
        alternative_quotes.map { alternative_quote_form(_1) }
      end

      def completed?
        PriorAuthority::Tasks::AlternativeQuotes.new(application:).completed?
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
            text: check_missing(application.no_alternative_quote_reason) do
                    simple_format(application.no_alternative_quote_reason)
                  end
          }
        ]
      end

      def alternative_quotes
        @alternative_quotes ||= application.alternative_quotes
      end

      def alternative_quote_summary_html(quote)
        form = alternative_quote_form(quote)

        alternative_quote_summary_html = [
          check_missing(quote.contact_full_name),
          document_link(quote),
          check_missing(form.total_cost) do
            LaaCrimeFormsCommon::NumberTo.pounds(form.total_cost)
          end
        ].compact.join('<br>')

        sanitize(alternative_quote_summary_html, tags: %w[a br strong])
      end

      def alternative_quote_form(quote)
        PriorAuthority::Steps::AlternativeQuotes::DetailForm.build(quote, application:)
      end

      def document_link(quote)
        return if quote.document&.file_name.blank?

        govuk_link_to(quote.document.file_name,
                      url_helper.download_path(quote.document))
      end
    end
  end
end
