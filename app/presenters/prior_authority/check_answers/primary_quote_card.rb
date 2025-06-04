# frozen_string_literal: true

module PriorAuthority
  module CheckAnswers
    class PrimaryQuoteCard < Base
      attr_reader :application, :service_cost_form, :travel_detail_form, :verbose

      def initialize(application, verbose: false, skip_links: false)
        @group = 'about_request'
        @section = 'primary_quote_summary'
        @application = application
        @verbose = verbose
        @skip_links = skip_links

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

      def base_rows
        [
          *service_rows,
          quote_upload_row,
          *related_to_post_mortem,
          *ordered_by_court,
          prior_authority_granted_row,
          *travel_cost_reason,
        ]
      end

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

      def completed?
        PriorAuthority::Tasks::PrimaryQuote.new(application:).completed?
      end

      private

      delegate :primary_quote, to: :application

      def service_rows
        [
          {
            head_key: 'service_name',
            text: check_missing(service_cost_form.service_name),
          },
          {
            head_key: 'service_details',
            text: service_details_html,
          }
        ]
      end

      def quote_upload_row
        {
          head_key: 'quote_upload',
          text: document_link,
        }
      end

      def prior_authority_granted_row
        {
          head_key: 'prior_authority_granted',
          text: check_missing(application.prior_authority_granted?, I18n.t("generic.#{application.prior_authority_granted?}")),
        }
      end

      def service_details_html
        organisation_details = [
          check_missing(primary_quote.organisation),
          check_missing(primary_quote.town),
          check_missing(primary_quote.postcode)
        ].compact.join(', ')

        service_details_html = [
          check_missing(primary_quote.contact_full_name),
          check_missing(organisation_details)
        ].compact.join('<br>')

        sanitize(service_details_html, tags: %w[br strong])
      end

      def document_link
        if @skip_links
          primary_quote.document.file_name
        else
          govuk_link_to(primary_quote.document.file_name,
                        url_helper.download_path(primary_quote.document))
        end
      end

      def related_to_post_mortem
        return [] unless service_cost_form.post_mortem_relevant

        [
          {
            head_key: 'related_to_post_mortem',
            text: check_missing(primary_quote.related_to_post_mortem?,
                                I18n.t("generic.#{primary_quote.related_to_post_mortem?}")),
          },
        ]
      end

      def ordered_by_court
        return [] unless service_cost_form.court_order_relevant

        [
          {
            head_key: 'ordered_by_court',
            text: check_missing(primary_quote.ordered_by_court?, I18n.t("generic.#{primary_quote.ordered_by_court?}")),
          },
        ]
      end

      def travel_cost_reason
        return [] if verbose # In verbose mode, travel costs are handled separately
        return [] unless travel_detail_form.travel_costs_require_justification?

        [
          {
            head_key: 'travel_cost_reason',
            text: check_missing(application.primary_quote.travel_cost_reason,
                                simple_format(application.primary_quote.travel_cost_reason)),
          },
        ]
      end
    end
  end
end
