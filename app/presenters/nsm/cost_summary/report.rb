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
        @summary = Summary.new(claim)
      end

      def sections
        items.map do |name, data|
          {
            card: {
              title: data.title,
              actions: actions(name)
            },
            table: {
              head: header_row(time_column: name == :work_items),
              rows: [*data.rows, footer_row(data, time_column: name == :work_items)],
            }
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

      def header_row(time_column: false)
        [
          { text: translate('.header.item') },
          ({ text: translate('.header.time') } if time_column),
          { text: translate('.header.net_cost'), classes: 'govuk-table__header--numeric' },
        ].compact
      end

      def footer_row(data, time_column: false)
        [
          { text: translate('.footer.total'), classes: 'govuk-table__header' },
          ({} if time_column),
          { text: NumberTo.pounds(data.total_cost), classes: 'govuk-table__cell--numeric govuk-summary-list__value-bold' }
        ].compact
      end
    end
  end
end
