module Sorters
  module WorkItemsSorter
    extend ArraySorter

    PRIMARY_SORT_FIELDS = {
      'line_item' => :position,
      'item' => ->(item) { item.work_type.to_s },
      'date' => :completed_on,
      'fee_earner' => :fee_earner,
      'time' => :time_spent,
      'uplift' => ->(item) { item.uplift.to_f },
      'net_cost' => :total_cost,
    }.freeze
  end
end
