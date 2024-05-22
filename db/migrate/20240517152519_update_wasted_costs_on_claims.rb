class UpdateWastedCostsOnClaims < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    Claim.where(wasted_costs: nil).in_batches do |relation|
      relation.update_all wasted_costs: 'no'
      sleep(0.01) # throttle
    end
  end
end
