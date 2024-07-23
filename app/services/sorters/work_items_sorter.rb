module Sorters
  module WorkItemsSorter
    PRIMARY_SORT_FIELDS = {
      'item' => :position,
      'cost' => -> { _1.work_type.to_s },
      'date' => :completed_on,
      'fee_earner' => :fee_earner,
      'claimed_time' => :time_spent,
      'claimed_uplift' => -> { _1.uplift.to_f },
      'claimed_net_cost' => :provider_requested_amount,
      'allowed_net_cost' => -> { _1.any_adjustments? ? _1.caseworker_amount : 0 }
    }.freeze

    class << self
      def call(items, sort_by, sort_direction)
        sorted_items = sort_by_field(items, sort_by)
        sorted_items = sorted_items.reverse if sort_direction == 'descending'
        sorted_items
      end

      def sort_by_field(items, sort_by)
        sort_field = PRIMARY_SORT_FIELDS.fetch(sort_by)

        items.sort_by do |item|
          if sort_field.respond_to?(:call)
            [sort_field.call(item), item.position]
          else
            [item.send(sort_field), item.position]
          end
        end
      end
    end
  end
end
