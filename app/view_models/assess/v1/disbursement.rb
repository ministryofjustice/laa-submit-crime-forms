module Assess
  module V1
    class Disbursement < Assess::BaseWithAdjustments
      LINKED_TYPE = 'disbursements'.freeze
      ID_FIELDS = %w[id].freeze
      attribute :disbursement_type, :translated
      attribute :other_type, :translated
      # TODO: import time_period code from provider app
      attribute :miles, :decimal, precision: 10, scale: 3
      attribute :pricing, :decimal, precision: 10, scale: 2
      attribute :total_cost_without_vat, :decimal, precision: 10, scale: 2
      attribute :vat_rate, :decimal, precision: 3, scale: 2
      attribute :disbursement_date, :date
      attribute :id, :string
      attribute :details, :string
      attribute :prior_authority, :string
      attribute :apply_vat, :string
      attribute :vat_amount, :decimal, precision: 10, scale: 2

      def provider_requested_total_cost_without_vat
        value_from_first_event('total_cost_without_vat') || total_cost_without_vat
      end

      def provider_requested_vat_amount
        value_from_first_event('vat_amount') || vat_amount
      end

      def provider_requested_total_cost
        @provider_requested_total_cost ||= CostCalculator.cost(:disbursement, self)
      end

      def caseworker_total_cost
        total_cost_without_vat.zero? ? 0 : provider_requested_total_cost
      end

      def form_attributes
        attributes.slice('total_cost_without_vat').merge(
          'explanation' => previous_explanation
        )
      end

      # rubocop:disable Metrics/AbcSize
      def disbursement_fields
        table_fields = {}
        table_fields[:date] = disbursement_date.strftime('%d %b %Y')
        table_fields[:type] = type_name.capitalize
        table_fields[:miles] = miles.to_s if miles.present?
        table_fields[:details] = details.capitalize
        table_fields[:prior_authority] = prior_authority.capitalize
        table_fields[:vat] = format_vat_rate(vat_rate) if apply_vat == 'true'
        table_fields[:total] = NumberTo.pounds(CostCalculator.cost(:disbursement, self))

        table_fields
      end
      # rubocop:enable Metrics/AbcSize

      def format_vat_rate(rate)
        "#{(rate * 100).to_i}%"
      end

      def type_name
        other_type.to_s.presence || disbursement_type.to_s
      end

      def table_fields
        [
          type_name,
          NumberTo.pounds(provider_requested_total_cost),
          apply_vat == 'true' ? format_vat_rate(vat_rate) : '0%',
          adjustments.any? ? NumberTo.pounds(caseworker_total_cost) : '',
        ]
      end
    end
  end
end
