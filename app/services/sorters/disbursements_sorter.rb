module Sorters
  module DisbursementsSorter
    extend ArraySorter

    PRIMARY_SORT_FIELDS = {
      'line_item' => :position,
      'item' => :translated_disbursement_type,
      'date' => :disbursement_date,
      'net_cost' => :total_cost_without_vat,
      'allowed_net_cost' => -> { _1.allowed_total_cost_without_vat.to_d },
      'vat' => :vat,
      'allowed_vat' => :allowed_vat,
      'gross_cost' => :total_cost,
      'allowed_gross_cost' => :allowed_total_cost,
    }.freeze
  end
end
