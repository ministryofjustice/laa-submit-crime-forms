# frozen_string_literal: true

module CheckAnswers
  class LettersCallsCard < Base
    attr_reader :letters_calls_form

    def initialize(claim)
      @letters_calls_form = Steps::LettersCallsForm.build(claim)
      @group = 'about_claim'
      @section = 'letters_calls'
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def row_data
      [
        {
          head_key: 'items',
          text: ApplicationController.helpers.sanitize(translate_table_key(section, 'items_total'), tags: %w[strong])
        },
        {
          head_key: 'letters',
          text: letters
        },
        {
          head_key: 'letters_uplift',
          text: percent_value(letters_calls_form.letters_uplift)
        },
        {
          head_key: 'letters_payment',
          text: currency_value(letters_calls_form.letters_after_uplift)
        },
        {
          head_key: 'calls',
          text: calls
        },
        {
          head_key: 'calls_uplift',
          text: percent_value(letters_calls_form.calls_uplift)
        },
        {
          head_key: 'calls_payment',
          text: currency_value(letters_calls_form.calls_after_uplift)
        },
        {
          head_key: 'total',
          text: total_cost,
          footer: true
        }
      ]
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    private

    def percent_value(value)
      uplift = value || 0
      translate_table_key(section, 'uplift_value', value: uplift)
    end

    def currency_value(value)
      NumberTo.pounds(value || 0)
    end

    def total_cost
      text = "<strong>#{currency_value(letters_calls_form.total_cost)}</strong>"
      ApplicationController.helpers.sanitize(text, tags: %w[strong])
    end

    def letters
      letters_calls_form.letters || 0
    end

    def calls
      letters_calls_form.calls || 0
    end
  end
end
