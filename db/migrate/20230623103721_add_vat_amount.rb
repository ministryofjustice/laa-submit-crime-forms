class AddVatAmount < ActiveRecord::Migration[7.0]
  def change
    add_column :disbursements, :vat_amount, :decimal, precision: 2
    rename_column :disbursements, :total_cost, :total_cost_without_vat
    change_column :disbursements, :total_cost_without_vat, :decimal, precision: 2
  end
end
