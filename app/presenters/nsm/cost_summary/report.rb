module Nsm
  module CostSummary
    class Report < Base
      include GovukLinkHelper
      include GovukVisuallyHiddenHelper
      include ActionView::Helpers::UrlHelper

      attr_reader :claim, :items, :summary

      def initialize(claim)
        @claim = claim
        @items = {
          work_items: WorkItems.new(claim.work_items, claim),
          letters_calls: LettersCalls.new(claim),
          additional_fees: (AdditionalFees.new(claim) if claim.additional_fees_applicable?),
          disbursements: Disbursements.new(claim.disbursements.by_age, claim)
        }.compact
        @summary = CheckAnswers::CostSummaryCard.new(claim, has_card: false, title_key: 'your_cost_summary')
      end

      def sections
        items.map do |name, data|
          {
            card: {
              title: data.title,
              actions: actions(data.change_key || name)
            },
            table: {
              head: data.header_row,
              rows: [*data.rows, data.footer_row],
              first_cell_is_header: true,
            },
            caption: { text: data.caption, classes: 'govuk-visually-hidden' },
          }
        end
      end

      def total_cost
        NumberTo.pounds claim.totals[:totals][:claimed_total_inc_vat]
      end

      private

      def actions(key)
        helper = Rails.application.routes.url_helpers
        [
          govuk_link_to(
            translate('.change'),
            helper.url_for(controller: "nsm/steps/#{key}", action: :edit, id: claim.id, only_path: true)
          ),
        ]
      end
    end
  end
end
