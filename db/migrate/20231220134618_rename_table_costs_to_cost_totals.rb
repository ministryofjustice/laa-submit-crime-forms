class RenameTableCostsToCostTotals < ActiveRecord::Migration[7.1]
  def change
    rename_table :costs, :cost_totals
  end
end
