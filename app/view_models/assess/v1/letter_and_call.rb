module Assess
  module V1
    class LetterAndCall < Assess::BaseWithAdjustments
      LINKED_TYPE = 'letters_and_calls'.freeze
      ID_FIELDS = %w[type value].freeze

      attribute :type, :translated
      attribute :count, :integer
      attribute :uplift, :integer
      attribute :pricing, :float

      def provider_requested_amount
        CostCalculator.cost(:letter_and_call, self, :provider_requested)
      end

      def provider_requested_uplift
        @provider_requested_uplift ||= value_from_first_event('uplift') || uplift
      end

      def provider_requested_count
        value_from_first_event('count') || count
      end

      def caseworker_amount
        @caseworker_amount ||= CostCalculator.cost(:letter_and_call, self, :caseworker)
      end

      def caseworker_uplift
        uplift.to_i
      end

      def caseworker_count
        count
      end

      def allowed_amount
        adjustments.any? ? caseworker_amount : provider_requested_amount
      end

      def type_name
        type.to_s.downcase
      end

      def id
        type.value
      end

      def form_attributes
        attributes.slice!('pricing', 'adjustments').merge(
          'type' => type.value,
          'explanation' => previous_explanation,
        )
      end

      def table_fields
        [
          type.to_s,
          count.to_s,
          "#{provider_requested_uplift.to_i}%",
          NumberTo.pounds(provider_requested_amount),
          adjustments.any? ? "#{caseworker_uplift}%" : '',
          adjustments.any? ? NumberTo.pounds(caseworker_amount) : '',
        ]
      end

      def uplift?
        !provider_requested_uplift.to_i.zero?
      end
    end
  end
end
