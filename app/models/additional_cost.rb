class AdditionalCost < ApplicationRecord
  belongs_to :prior_authority_application

  def total_cost
    if unit_type == 'per_hour'
      (cost_per_hour * period/60)
    elsif unit_type == 'per_item'
      (cost_per_item * items)
    end
  end
end
