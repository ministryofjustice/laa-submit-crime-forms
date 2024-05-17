class AddWastedCostsToClaims < ActiveRecord::Migration[7.1]
  def change
    add_column :claims, :wasted_costs, :string
  end
end
