module CostSummary
  class LettersCalls < Base
    attr_reader :letters_calls_form

    def initialize(claim)
      @letters_calls_form = Steps::LettersCallsForm.build(claim)
    end

    def rows
      [
        {
          key: { text: t("letters") },
          value: { text: f(letters_calls_form.letters_total) },
        },
        {
          key: { text: t("calls") },
          value: { text: f(letters_calls_form.calls_total) },
        }
      ]
    end

    def total_cost
      letters_calls_form.total_cost
    end

    def title
      t("letters_calls", total: f(total_cost))
    end
  end
end
