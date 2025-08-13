module Nsm
  module CostSummary
    class AdditionalFees < Base
      TRANSLATION_KEY = self
      MIDDLE_COLUMN = false
      attr_reader :claim

      def initialize(claim)
        @claim = claim
        super()
      end

      def rows
        additional_fees.map do |key, value|
          [
            { text: translated_text(key), classes: 'govuk-table__header' },
            { text: LaaCrimeFormsCommon::NumberTo.pounds(value[:claimed_total_exc_vat]), classes: 'govuk-table__cell--numeric' },
          ]
        end
      end

      def additional_fees
        claim.totals[:additional_fees].except(:total)
      end

      def total_cost
        @total_cost ||= claim.totals.dig(:additional_fees, :total, :claimed_total_exc_vat)
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

      def change_key
        'youth_court_claim_additional_fee'
      end
    end
  end
end
