class Disbursement < ApplicationRecord
  belongs_to :claim

  def total_cost
    return unless total_cost_without_vat && vat_amount

    total_cost_without_vat + vat_amount
  end
end
