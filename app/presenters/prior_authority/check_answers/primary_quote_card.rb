# frozen_string_literal: true

module PriorAuthority
  module CheckAnswers
    class PrimaryQuoteCard < Base
      attr_reader :application, :service_cost_form

      def initialize(application)
        @group = 'about_request'
        @section = 'primary_quote_summary'
        @application = application
        @service_cost_form = PriorAuthority::Steps::ServiceCostForm.build(
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
          *related_to_post_mortem,
          {
            head_key: 'quote_upload',
            text: primary_quote.document.file_name,
          },
          *ordered_by_court,
          {
            head_key: 'prior_authority_granted',
            text: I18n.t("generic.#{application.prior_authority_granted?}"),
          },
          *travel_cost_reason,
          *summary,
        ]
      end
      # rubocop:enable Metrics/MethodLength

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
        return [] if application.client_detained?

        [
          {
            head_key: 'travel_cost_reason',
            text: application.primary_quote.travel_cost_reason,
          },
        ]
      end

      # TODO: this needs to be modified to add the list or table nested in a single list item/column
      def summary
        [
          {
            head_key: 'summary',
            text: PrimaryQuoteCardSummary.new(application).render,
          },
        ]
      end
    end
  end
end
