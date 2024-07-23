module Sorters
  module WorkItemsSorter
    PRIMARY_SORT_FIELDS = {
      'line_item' => :position,
      'item' => -> { _1.work_type.to_s },
      'date' => :completed_on,
      'fee_earner' => :fee_earner,
      'time' => :time_spent,
      'uplift' => -> { _1.uplift.to_f },
      'net_cost' => :total_cost,
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
