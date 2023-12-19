module Assess
  module V1
    class WorkItem < Assess::BaseWithAdjustments
      LINKED_TYPE = 'work_items'.freeze
      ID_FIELDS = %w[id].freeze

      attribute :id, :string
      attribute :work_type, :translated
      attribute :time_spent, :time_period
      attribute :completed_on, :date

      attribute :pricing, :float
      attribute :uplift, :integer
      attribute :fee_earner, :string

      def provider_requested_amount
        @provider_requested_amount ||= CostCalculator.cost(:work_item, self, :provider_requested)
      end

      def provider_requested_time_spent
        @provider_requested_time_spent ||= value_from_first_event('time_spent') || time_spent.to_i
      end

      def provider_requested_uplift
        @provider_requested_uplift ||= value_from_first_event('uplift') || uplift.to_i
      end

      def caseworker_amount
        @caseworker_amount ||= CostCalculator.cost(:work_item, self, :caseworker)
      end

      def caseworker_time_spent
        time_spent.to_i
      end

      def caseworker_uplift
        uplift.to_i
      end

      def uplift?
        !provider_requested_uplift.to_i.zero?
      end

      def form_attributes
        attributes.slice('time_spent', 'uplift').merge(
          'explanation' => previous_explanation
        )
      end

      def table_fields
        [
          work_type.to_s,
          "#{provider_requested_uplift.to_i}%",
          NumberTo.pounds(provider_requested_amount).to_s,
          adjustments.any? ? "#{caseworker_uplift}%" : '',
          adjustments.any? ? NumberTo.pounds(caseworker_amount) : '',
        ]
      end

      def attendance?
        %w[attendance_with_counsel attendance_without_counsel].include?(work_type.value)
      end
    end
  end
end
