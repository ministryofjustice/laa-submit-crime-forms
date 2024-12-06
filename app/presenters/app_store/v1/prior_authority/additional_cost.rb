module AppStore
  module V1
    module PriorAuthority
      class AdditionalCost < AppStore::V1::Base
        attribute :name, :string
        attribute :description, :string
        attribute :unit_type, :string
        adjustable_attribute :cost_per_hour, :decimal
        adjustable_attribute :cost_per_item, :decimal
        adjustable_attribute :items, :integer
        adjustable_attribute :period, :integer
        attribute :created_at, :datetime
        attribute :updated_at, :datetime
        attribute :adjustment_comment, :string

        def total_cost_allowed
          if unit_type == 'per_hour'
            (assessed_cost_per_hour * assessed_period / 60).round(2)
          else
            assessed_items * assessed_cost_per_item
          end
        end
      end
    end
  end
end
