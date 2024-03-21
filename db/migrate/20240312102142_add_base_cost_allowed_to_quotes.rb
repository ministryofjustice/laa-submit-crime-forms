class AddBaseCostAllowedToQuotes < ActiveRecord::Migration[7.1]
  def change
    change_table :quotes, bulk: true do |t|
      t.decimal "base_cost_allowed", precision: 10, scale: 2
      t.decimal "travel_cost_allowed", precision: 10, scale: 2
    end

    add_column :additional_costs, :total_cost_allowed, :decimal, precision: 10, scale: 2
  end
end
