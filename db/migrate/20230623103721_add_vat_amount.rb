class AddVatAmount < ActiveRecord::Migration[7.0]
  def change
    add_column :disbursements, :vat_amount, :decimal, precision: 10, scale: 2
    rename_column :disbursements, :total_cost, :total_cost_without_vat
    reversible do |direction|
      change_table :disbursements do |t|
        direction.up   do
          t.change :total_cost_without_vat, :decimal, precision: 10, scale: 2
          t.change :miles, 'decimal(10,3) USING CAST(miles AS decimal)'
        end
        direction.down do
          t.change :total_cost_without_vat, :float
          t.change :miles, :string
        end
      end
    end
  end
end
