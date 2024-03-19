class AdditionalCost < ApplicationRecord
  belongs_to :prior_authority_application

  def total_cost
    PriorAuthority::Steps::AdditionalCosts::DetailForm.build(self, application: prior_authority_application).total_cost
  end
end
