module PriorAuthority
  module Steps
    class QuoteCostForm < ::Steps::BaseFormObject
      def self.attribute_names
        super - %w[service_type]
      end

      def initialize(attrs)
        attrs[:service_type] = attrs[:application].service_type
        super(attrs)
      end

      PER_ITEM = 'per_item'.freeze
      PER_HOUR = 'per_hour'.freeze
      VARIABLE = 'variable'.freeze
      COST_TYPES = [PER_ITEM, PER_HOUR].freeze

      attribute :service_type, :value_object, source: QuoteServices

      attribute :user_chosen_cost_type, :string
      attribute :items, :fully_validatable_integer
      attribute :cost_per_item, :gbp
      attribute :period, :time_period
      attribute :cost_per_hour, :gbp

      def variable_cost_type?
        service_rule.cost_type == :variable
      end

      def formatted_total_cost
        NumberTo.pounds(total_cost)
      end

      def total_cost
        per_item? ? item_cost : time_cost
      end

      def per_item?
        cost_type == PER_ITEM
      end

      def per_hour?
        cost_type == PER_HOUR
      end

      def item_type
        service_rule.item
      end

      def service_name
        if service_type == QuoteServices.new(:custom)
          application.custom_service_name
        else
          service_type.translated
        end
      end

      def cost_type
        @cost_type ||= variable_cost_type? ? user_chosen_cost_type : service_rule.cost_type.to_s
      end

      private

      def item_cost
        return 0 unless cost_per_item.to_f.positive? && items.to_i.positive?

        cost_per_item * items
      end

      def time_cost
        return 0 if period.is_a?(Hash)
        return 0 unless cost_per_hour.to_d.positive? && period.to_i.positive?

        (cost_per_hour * (period.hours + (period.minutes / 60.0))).round(2)
      end

      def service_rule
        @service_rule ||= ServiceTypeRule.build(service_type)
      end

      def reset_attributes
        {
          PER_ITEM => { period: nil, cost_per_hour: nil },
          PER_HOUR => { items: nil, cost_per_item: nil }
        }.fetch(cost_type)
      end
    end
  end
end
