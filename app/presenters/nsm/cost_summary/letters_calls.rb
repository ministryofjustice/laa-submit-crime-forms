module Nsm
  module CostSummary
    class LettersCalls < Base
      TRANSLATION_KEY = self
      attr_reader :claim

      def initialize(claim)
        @claim = claim
        super()
      end

      def rows
        [
          [
            { text: translate('letters'), classes: 'govuk-table__header' },
            { text: claim.letters.to_i, classes: 'govuk-table__cell--numeric' },
            { text: LaaCrimeFormsCommon::NumberTo.pounds(claim.letters_after_uplift || 0), classes: 'govuk-table__cell--numeric' },
          ],
          [
            { text: translate('calls'), classes: 'govuk-table__header' },
            { text: claim.calls.to_i, classes: 'govuk-table__cell--numeric' },
            { text: LaaCrimeFormsCommon::NumberTo.pounds(claim.calls_after_uplift || 0), classes: 'govuk-table__cell--numeric' },
          ]
        ]
      end

      def total_cost
        claim.letters_and_calls_total_cost || 0
      end

      def title
        translate('letters_calls')
      end

      def header_row
        [
          { text: translate('.header.item') },
          { text: translate('.header.number'), classes: 'govuk-table__header--numeric' },
          { text: translate('.header.net_cost'), classes: 'govuk-table__header--numeric' },
        ]
      end
    end
  end
end
