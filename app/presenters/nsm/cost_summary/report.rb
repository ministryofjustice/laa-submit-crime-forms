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
          disbursements: Disbursements.new(claim.disbursements.by_age, claim)
        }
        @summary = CheckAnswers::CostSummaryCard.new(claim, has_card: false, title_key: 'your_cost_summary')
      end

      def sections
        items.map do |name, data|
          {
            card: {
              title: data.title,
              actions: actions(name)
            },
            table: {
              head: data.header_row,
              rows: [*data.rows, footer_row(data, middle_column: name != :disbursements)],
              first_cell_is_header: true,
            },
            caption: { text: data.caption, classes: 'govuk-visually-hidden' },
          }
        end
      end

      def total_cost
        NumberTo.pounds summary.total_gross
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

      def footer_row(data, middle_column: false)
        [
          { text: translate('.footer.total'), classes: 'govuk-table__header' },
          ({} if middle_column),
          { text: data.total_cost_cell, classes: 'govuk-table__cell--numeric govuk-summary-list__value-bold' }
        ].compact
      end
    end
  end
end
