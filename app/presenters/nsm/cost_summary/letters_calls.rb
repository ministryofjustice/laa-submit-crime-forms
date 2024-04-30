module Nsm
  module CostSummary
    class LettersCalls < Base
      TRANSLATION_KEY = self
      attr_reader :letters_calls_form

      def initialize(claim)
        @claim = claim
        @letters_calls_form = Nsm::Steps::LettersCallsForm.build(claim)
      end

      def rows
        [
          [
            { text: translate('letters'), classes: 'govuk-table__header' },
            { text: NumberTo.pounds(letters_calls_form.letters_after_uplift || 0), classes: 'govuk-table__cell--numeric' },
          ],
          [
            { text: translate('calls'), classes: 'govuk-table__header' },
            { text: NumberTo.pounds(letters_calls_form.calls_after_uplift || 0), classes: 'govuk-table__cell--numeric' },
          ]
        ]
      end

      def total_cost
        letters_calls_form.total_cost || 0
      end

      def title
        translate('letters_calls')
      end
    end
  end
end
