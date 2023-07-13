module CostSummary
  class LettersCalls < Base
    attr_reader :letters_calls_form

    def initialize(claim)
      @letters_calls_form = Steps::LettersCallsForm.build(claim)
    end

    def rows
      [
        {
          key: { text: translate('letters'), classes: 'govuk-summary-list__value-width-50' },
          value: { text: NumberTo.pounds(letters_calls_form.letters_after_uplift) },
        },
        {
          key: { text: translate('calls'), classes: 'govuk-summary-list__value-width-50' },
          value: { text: NumberTo.pounds(letters_calls_form.calls_after_uplift) },
        }
      ]
    end

    delegate :total_cost, to: :letters_calls_form

    def title
      translate('letters_calls', total: NumberTo.pounds(total_cost))
    end
  end
end
