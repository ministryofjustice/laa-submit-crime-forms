module Sorters
  module WorkItemsSorter
    extend ArraySorter

    PRIMARY_SORT_FIELDS = {
      'line_item' => :position,
      'item' => -> { _1.work_type.to_s },
      'date' => :completed_on,
      'fee_earner' => :fee_earner,
      'time' => :time_spent,
      'uplift' => -> { _1.uplift.to_f },
      'net_cost' => :total_cost,
    }.freeze
  end
end
