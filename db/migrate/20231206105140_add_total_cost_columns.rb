class AddTotalCostColumns < ActiveRecord::Migration[7.1]
  def change
    add_column :claims, :submitted_total, :float
    add_column :claims, :submitted_total_inc_vat, :float
    add_column :claims, :adjusted_total, :float
    add_column :claims, :adjusted_total_inc_vat, :float
  end
end
