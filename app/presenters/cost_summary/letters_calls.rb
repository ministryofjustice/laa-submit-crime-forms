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
          value: { text: NumberTo.pounds(letters_calls_form.letters_after_uplift || 0) },
        },
        {
          key: { text: translate('calls'), classes: 'govuk-summary-list__value-width-50' },
          value: { text: NumberTo.pounds(letters_calls_form.calls_after_uplift || 0) },
        }
      ]
    end

    def total_cost
      letters_calls_form.total_cost || 0
    end

    def title
      translate('letters_calls', total: NumberTo.pounds(total_cost || 0))
    end
  end
end
