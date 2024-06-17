class AddMissingFieldsToDisbursements < ActiveRecord::Migration[7.1]
  def change
    add_column :disbursements, :allowed_miles, :decimal, precision: 10, scale: 3
    add_column :disbursements, :allowed_apply_vat, :string
  end
end
