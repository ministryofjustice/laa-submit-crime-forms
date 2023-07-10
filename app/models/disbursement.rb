class Disbursement < ApplicationRecord
  belongs_to :claim

  scope :by_age, -> { order(:disbursement_date, :created_at) }

  def total_cost
    return unless total_cost_without_vat && vat_amount

    total_cost_without_vat + vat_amount
  end
end
