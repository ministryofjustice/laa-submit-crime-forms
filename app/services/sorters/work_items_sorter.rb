module Sorters
  module WorkItemsSorter
    extend ArraySorter

    PRIMARY_SORT_FIELDS = {
      'line_item' => :position,
      'item' => -> { _1.work_type.to_s },
      'date' => :completed_on,
      'fee_earner' => :fee_earner,
      'adjustment_comment' => :adjustment_comment,
      'time' => :time_spent,
      'allowed_time' => -> { _1.allowed_time_spent || _1.time_spent },
      'uplift' => -> { _1.uplift.to_f },
      'allowed_uplift' => -> { (_1.allowed_uplift || _1.uplift).to_f },
      'net_cost' => :total_cost,
      'allowed_net_cost' => :allowed_total_cost,
    }.freeze
  end
end
