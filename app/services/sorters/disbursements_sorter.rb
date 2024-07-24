module Sorters
  module DisbursementsSorter
    extend ArraySorter

    PRIMARY_SORT_FIELDS = {
      'line_item' => :position,
      'item' => ->(item) { item.disbursement_type.to_s },
      'date' => :disbursement_date,
      'net_cost' => :total_cost_without_vat,
      'vat' => :vat,
      'gross_cost' => :total_cost
    }.freeze
  end
end
