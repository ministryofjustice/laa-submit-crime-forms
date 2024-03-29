module Nsm
  module CostSummary
    class LettersCalls < Base
      TRANSLATION_KEY = self
      HALF_WIDTH = 'govuk-summary-list__value-width-50'.freeze
      attr_reader :letters_calls_form

      def initialize(claim)
        @claim = claim
        @letters_calls_form = Nsm::Steps::LettersCallsForm.build(claim)
      end

      def rows
        [
          {
            key: { text: translate('letters'), classes: HALF_WIDTH },
            value: { text: NumberTo.pounds(letters_calls_form.letters_after_uplift || 0) },
          },
          {
            key: { text: translate('calls'), classes: HALF_WIDTH },
            value: { text: NumberTo.pounds(letters_calls_form.calls_after_uplift || 0) },
          }
        ]
      end

      def footer_vat_row
        return [] if total_cost_inc_vat.zero?

        [
          {
            key: { text: translate('.footer.total_inc_vat'), classes: HALF_WIDTH },
            value: { text: NumberTo.pounds(total_cost_inc_vat), classes: 'govuk-summary-list__value-bold' },
          }
        ]
      end

      def total_cost
        letters_calls_form.total_cost || 0
      end

      def total_cost_inc_vat
        letters_calls_form.total_cost_inc_vat || 0
      end

      def title
        translate('letters_calls', total: NumberTo.pounds(vat_registered ? total_cost_inc_vat : total_cost || 0))
      end
    end
  end
end
