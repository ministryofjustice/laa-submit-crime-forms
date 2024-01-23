# frozen_string_literal: true

module CheckAnswers
  class LettersCallsCard < Base
    attr_reader :letters_calls_form

    def initialize(claim)
      @claim = claim
      @letters_calls_form = Steps::LettersCallsForm.build(claim)
      @group = 'about_claim'
      @section = 'letters_calls'
    end

    # rubocop:disable Metrics/AbcSize
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
      ] +
        letters_uplift_fields +
        [
          {
            head_key: 'letters_payment',
            text: currency_value(letters_calls_form.letters_after_uplift)
          },
          {
            head_key: 'calls',
            text: calls
          },
        ] +
        calls_uplift_fields +
        [
          {
            head_key: 'calls_payment',
            text: currency_value(letters_calls_form.calls_after_uplift)
          },
          {
            head_key: 'total',
            text: total_cost,
            footer: true
          }
        ] + total_inc_vat_fields
    end
    # rubocop:enable Metrics/AbcSize

    private

    def letters_uplift_fields
      return [] unless letters_calls_form.allow_uplift?

      [
        {
          head_key: 'letters_uplift',
          text: percent_value(letters_calls_form.letters_uplift)
        },
      ]
    end

    def calls_uplift_fields
      return [] unless letters_calls_form.allow_uplift?

      [
        {
          head_key: 'calls_uplift',
          text: percent_value(letters_calls_form.calls_uplift)
        },
      ]
    end

    def total_inc_vat_fields
      return [] unless @claim.firm_office.vat_registered == YesNoAnswer::YES.to_s

      [
        {
          head_key: 'total_inc_vat',
          text: total_cost_inc_vat,
        }
      ]
    end

    def percent_value(value)
      uplift = value || 0
      translate_table_key(section, 'uplift_value', value: uplift)
    end

    def total_cost
      format_total(letters_calls_form.total_cost)
    end

    def total_cost_inc_vat
      format_total(letters_calls_form.total_cost_inc_vat)
    end

    def letters
      letters_calls_form.letters || 0
    end

    def calls
      letters_calls_form.calls || 0
    end
  end
end
