class ChangeCostColumnType < ActiveRecord::Migration[7.1]
  def change
    rename_column :costs, :type, :cost_type
  end
end
