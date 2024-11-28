module Nsm
  module CostSummary
    class AdditionalFees < Base
      TRANSLATION_KEY = self
      MIDDLE_COLUMN = false
      attr_reader :claim

      def initialize(claim)
        @claim = claim
      end

      def rows
        additional_fees.map do |key, value|
          [
            { text: translated_text(key), classes: 'govuk-table__header' },
            { text: NumberTo.pounds(value[:claimed_total_inc_vat]), classes: 'govuk-table__cell--numeric' },
          ]
        end
      end

      def additional_fees
        claim.totals[:additional_fees].except(:total)
      end

      def net_cost
        @net_cost ||= claim.totals.dig(:additional_fees, :total, :claimed_total_inc_vat)
      end

      def title
        translate('additional_fees')
      end

      def translated_text(fee_key)
        translate(fee_key.to_s)
      end

      def header_row
        [
          {},
          { text: translate('.header.net_cost'), classes: 'govuk-table__header--numeric' },
        ]
      end

      def total_cost_cell
        safe_join([tag.span(translate('.header.total_claimed'), class: 'govuk-visually-hidden'),
                   tag.strong(NumberTo.pounds(net_cost))])
      end

      def change_key
        'case_category'
      end
    end
  end
end
