module Sorters
  module DisbursementsSorter
    extend ArraySorter

    PRIMARY_SORT_FIELDS = {
      'line_item' => { sort_by: :position, sort_type: :integer },
      'item' =>  { sort_by: :translated_disbursement_type, sort_type: :string },
      'date' => { sort_by: :disbursement_date, sort_type: :date },
      'net_cost' => { sort_by: :total_cost_without_vat, sort_type: :number },
      'allowed_net_cost' => { sort_by: -> { _1.allowed_total_cost_without_vat.to_d }, sort_type: :number },
      'vat' => { sort_by: :vat, sort_type: :number },
      'allowed_vat' => { sort_by: :allowed_vat, sort_type: :number },
      'gross_cost' => { sort_by: :total_cost, sort_type: :number },
      'allowed_gross_cost' => { sort_by: :allowed_total_cost, sort_type: :number },
    }.freeze
  end
end
