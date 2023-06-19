module CostSummary
  class LettersCalls < Base
    attr_reader :letters_calls_form

    def initialize(claim)
      @letters_calls_form = Steps::LettersCallsForm.build(claim)
    end

    def rows
      [
        {
          key: { text: t('letters') },
          value: { text: f(letters_calls_form.letters_total) },
        },
        {
          key: { text: t('calls') },
          value: { text: f(letters_calls_form.calls_total) },
        }
      ]
    end

    delegate :total_cost, to: :letters_calls_form

    def title
      t('letters_calls', total: f(total_cost))
    end
  end
end
