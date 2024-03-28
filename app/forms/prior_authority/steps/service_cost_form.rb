module PriorAuthority
  module Steps
    class ServiceCostForm < QuoteCostForm
      def self.attribute_names
        super - %w[prior_authority_granted]
      end

      def initialize(attrs)
        # Prior authority granted is related to the application as a whole,
        # not a specific quote

        # This will be nil when loaded on edit, populated on updated
        attrs[:prior_authority_granted] = attrs[:application].prior_authority_granted if attrs[:prior_authority_granted].nil?

        super(attrs)
      end

      attribute :prior_authority_granted, :boolean
      attribute :ordered_by_court, :boolean
      attribute :related_to_post_mortem, :boolean

      validates :prior_authority_granted, inclusion: { in: [true, false], allow_nil: false }
      validates :ordered_by_court, inclusion: { in: [true, false], allow_nil: false }, if: :court_order_relevant
      validates :related_to_post_mortem, inclusion: { in: [true, false], allow_nil: false }, if: :post_mortem_relevant

      def adjusted_cost
        record.base_cost_allowed
      end

      include QuoteCostValidations

      delegate :court_order_relevant, :post_mortem_relevant, to: :service_rule

      private

      def persist!
        record.update!(attributes.except('prior_authority_granted', 'service_type').merge(reset_attributes))
        application.update(prior_authority_granted:)
      end
    end
  end
end
