# frozen_string_literal: true

module PriorAuthority
  module CheckAnswers
    class PrimaryQuoteCard < Base
      attr_reader :application, :service_cost_form, :travel_detail_form, :verbose

      def initialize(application, verbose: false)
        @group = 'about_request'
        @section = 'primary_quote_summary'
        @application = application
        @verbose = verbose

        @service_cost_form = PriorAuthority::Steps::ServiceCostForm.build(
          application.primary_quote,
          application:
        )

        @travel_detail_form = PriorAuthority::Steps::TravelDetailForm.build(
          application.primary_quote,
          application:
        )

        super()
      end

      def request_method
        :show
      end

      def row_data
        base_rows
      end

      def quote_summary
        @quote_summary ||= PriorAuthority::PrimaryQuoteSummary.new(application)
      end

      # rubocop:disable Metrics/MethodLength
      def base_rows
        [
          {
            head_key: 'service_name',
            text: service_cost_form.service_name,
          },
          {
            head_key: 'service_details',
            text: service_details_html,
          },
          {
            head_key: 'quote_upload',
            text: primary_quote.document.file_name,
          },
          *related_to_post_mortem,
          *ordered_by_court,
          {
            head_key: 'prior_authority_granted',
            text: I18n.t("generic.#{application.prior_authority_granted?}"),
          },
          *travel_cost_reason,
        ]
      end
      # rubocop:enable Metrics/MethodLength

      def template
        'prior_authority/steps/check_answers/primary_quote'
      end

      def nested_table_template
        filename = verbose ? 'primary_quote_details' : 'primary_quote_totals'
        "prior_authority/steps/check_answers/#{filename}"
      end

      def service_adjustment_comment
        primary_quote.service_adjustment_comment.presence
      end

      def travel_adjustment_comment
        primary_quote.travel_adjustment_comment.presence
      end

      private

      delegate :primary_quote, to: :application

      def service_details_html
        organisation_details = [primary_quote.organisation, primary_quote.postcode].compact.join(', ')
        service_details_html = [primary_quote.contact_full_name, organisation_details].compact.join('<br>')

        sanitize(service_details_html, tags: %w[br])
      end

      def related_to_post_mortem
        return [] unless service_cost_form.post_mortem_relevant

        [
          {
            head_key: 'related_to_post_mortem',
            text: I18n.t("generic.#{primary_quote.related_to_post_mortem?}"),
          },
        ]
      end

      def ordered_by_court
        return [] unless service_cost_form.court_order_relevant

        [
          {
            head_key: 'ordered_by_court',
            text: I18n.t("generic.#{primary_quote.ordered_by_court?}"),
          },
        ]
      end

      def travel_cost_reason
        return [] if verbose # In verbose mode, travel costs are handled separately
        return [] unless travel_detail_form.travel_costs_require_justification?

        [
          {
            head_key: 'travel_cost_reason',
            text: simple_format(application.primary_quote.travel_cost_reason),
          },
        ]
      end
    end
  end
end
