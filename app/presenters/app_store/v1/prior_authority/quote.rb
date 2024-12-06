module AppStore
  module V1
    module PriorAuthority
      class Quote < AppStore::V1::Base
        one :document, AppStore::V1::SupportingDocument

        attribute :organisation, :string
        attribute :postcode, :string
        attribute :primary, :boolean
        attribute :ordered_by_court, :boolean
        attribute :related_to_post_mortem, :boolean
        attribute :cost_type, :string
        adjustable_attribute :cost_per_hour, :decimal
        adjustable_attribute :cost_per_item, :decimal
        adjustable_attribute :items, :integer
        adjustable_attribute :period, :integer
        adjustable_attribute :travel_time, :integer
        adjustable_attribute :travel_cost_per_hour, :decimal
        attribute :travel_cost_reason, :string
        attribute :additional_cost_list, :string
        attribute :additional_cost_total, :decimal
        attribute :adjustment_comment, :string
        attribute :travel_adjustment_comment, :string
        attribute :contact_first_name, :string
        attribute :contact_last_name, :string
        attribute :town, :string

        def attribute_names
          super + ['user_chosen_cost_type']
        end

        def contact_full_name
          "#{contact_first_name} #{contact_last_name}"
        end

        # Needed to instantiate a quote detail form for a quote summary
        def build_document
          nil
        end

        # For variable cost types, the payload doesn't contain the user_chosen_cost_type,
        # just the cost_type, so we need to make the value available under the right attribute name
        alias user_chosen_cost_type cost_type

        def base_cost_allowed
          if cost_type == 'per_hour'
            (assessed_cost_per_hour * assessed_period / 60).round(2)
          else
            assessed_items * assessed_cost_per_item
          end
        end

        def travel_cost_allowed
          return 0 unless assessed_travel_time.to_i.positive? && assessed_travel_cost_per_hour.to_i.positive?

          (assessed_travel_time * assessed_travel_cost_per_hour / 60).round(2)
        end

        alias service_adjustment_comment adjustment_comment
      end
    end
  end
end
