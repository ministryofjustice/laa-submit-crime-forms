class RemoveCostTotalTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :cost_totals
  end
end
