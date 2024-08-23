module Sorters
  module WorkItemsSorter
    extend ArraySorter

    PRIMARY_SORT_FIELDS = {
      'line_item' => { sort_by: :position, sort_type: :number },
      'item' => { sort_by: -> { _1.work_type.to_s }, sort_type: :string },
      'date' => { sort_by: :completed_on, sort_type: :date },
      'fee_earner' => { sort_by: :fee_earner, sort_type: :string },
      'adjustment_comment' => { sort_by: :adjustment_comment, sort_type: :string },
      'time' => { sort_by: :time_spent, sort_type: :number },
      'allowed_time' => { sort_by: -> { _1.assessed_time_spent }, sort_type: :number },
      'uplift' => { sort_by: -> { _1.uplift.to_f }, sort_type: :number },
      'allowed_uplift' => { sort_by: -> { _1.assessed_uplift.to_f }, sort_type: :number },
      'net_cost' => { sort_by: :total_cost, sort_type: :number },
      'allowed_net_cost' => { sort_by: :allowed_total_cost, sort_type: :number },
    }.freeze
  end
end
