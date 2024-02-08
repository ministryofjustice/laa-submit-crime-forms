class SubmitToAppStore
  module PriorAuthority
    class AdditionalCostPayloadBuilder
      def initialize(application)
        @application = application
      end

      def payload
        @application.additional_costs.as_json(only: ATTRIBUTES)
      end

      ATTRIBUTES = %i[
        id
        name
        description
        unit_type
        cost_per_hour
        cost_per_item
        items
        period
      ].freeze
    end
  end
end
