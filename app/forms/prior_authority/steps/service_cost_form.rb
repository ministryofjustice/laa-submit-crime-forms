module PriorAuthority
  module Steps
    class ServiceCostForm < ::Steps::BaseFormObject
      def self.attribute_names
        super - ['prior_authority_granted']
      end

      def initialize(attrs)
        # Prior authority granted is related to the application as a whole,
        # not a specific quote

        # This will be nil when loaded on edit, populated on updated
        if attrs[:prior_authority_granted].nil?
          attrs[:prior_authority_granted] = attrs[:application].prior_authority_granted
        end

        # This will be nil when loaded on update, populated on edit
        attrs[:service_type] ||= attrs[:record].service_type
        super(attrs)
      end

      PER_ITEM = 'per_item'.freeze
      PER_HOUR = 'per_hour'.freeze
      VARIABLE = 'variable'.freeze
      COST_TYPES = [PER_ITEM, PER_HOUR].freeze

      attribute :service_type, :value_object, source: QuoteServices

      attribute :prior_authority_granted, :boolean
      attribute :ordered_by_court, :boolean
      attribute :related_to_post_mortem, :boolean
      attribute :user_chosen_cost_type, :string
      attribute :items, :integer
      attribute :cost_per_item, :decimal, precision: 10, scale: 2
      attribute :period, :time_period
      attribute :cost_per_hour, :decimal, precision: 10, scale: 2

      validates :prior_authority_granted, inclusion: { in: [true, false], allow_nil: false }
      validates :ordered_by_court, inclusion: { in: [true, false], allow_nil: false }, if: :court_order_relevant
      validates :related_to_post_mortem, inclusion: { in: [true, false], allow_nil: false }, if: :post_mortem_relevant
      validates :user_chosen_cost_type, inclusion: { in: COST_TYPES, allow_nil: false }, if: :variable_cost_type?

      validates :items, presence: true, numericality: { greater_than: 0 }, if: :per_item?
      validates :cost_per_item, presence: true, numericality: { greater_than: 0 }, if: :per_item?

      validates :period, presence: true, time_period: true, if: :per_hour?
      validates :cost_per_hour, presence: true, numericality: { greater_than: 0 }, if: :per_hour?

      delegate :court_order_relevant, :post_mortem_relevant, to: :service_rule

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
        service_type.translated
      end

      private

      def enforced_cost_type
        service_rule.cost_type == :per_item ? PER_ITEM : PER_HOUR
      end

      def cost_type
        variable_cost_type? ? user_chosen_cost_type : enforced_cost_type
      end

      def item_cost
        return 0 unless cost_per_item.to_f.positive? && items.to_i.positive?

        cost_per_item * items
      end

      def time_cost
        return 0 unless cost_per_hour.to_i.positive? && period.to_i.positive?

        (cost_per_hour * (period.hours + (period.minutes / 60.0))).round(2)
      end

      def persist!
        record.update!(attributes.except('prior_authority_granted'))
        application.update(prior_authority_granted:)
      end

      def service_rule
        @service_rule ||= ServiceTypeRule.build(service_type)
      end
    end
  end
end
