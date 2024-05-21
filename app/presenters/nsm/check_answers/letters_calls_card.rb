# frozen_string_literal: true

module Nsm
  module CheckAnswers
    class LettersCallsCard < Base
      attr_reader :claim

      def initialize(claim)
        @claim = claim
        @group = 'costs'
        @section = 'letters_calls'
      end

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
              text: currency_value(claim.letters_after_uplift)
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
              text: currency_value(claim.calls_after_uplift)
            },
            {
              head_key: 'total',
              text: total_cost,
              footer: true
            }
          ] + total_inc_vat_fields
      end

      private

      def letters_uplift_fields
        return [] unless claim.allow_uplift?

        [
          {
            head_key: 'letters_uplift',
            text: percent_value(claim.letters_uplift)
          },
        ]
      end

      def calls_uplift_fields
        return [] unless claim.allow_uplift?

        [
          {
            head_key: 'calls_uplift',
            text: percent_value(claim.calls_uplift)
          },
        ]
      end

      def total_inc_vat_fields
        return [] unless claim.firm_office.vat_registered == YesNoAnswer::YES.to_s

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
        format_total(claim.letters_and_calls_total_cost)
      end

      def total_cost_inc_vat
        format_total(claim.letters_and_calls_total_cost_inc_vat)
      end

      def letters
        claim.letters || 0
      end

      def calls
        claim.calls || 0
      end
    end
  end
end
