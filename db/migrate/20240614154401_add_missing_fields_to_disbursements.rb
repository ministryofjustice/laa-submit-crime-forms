class AddMissingFieldsToDisbursements < ActiveRecord::Migration[7.1]
  def change
    add_column :disbursements, :allowed_miles, :decimal, precision: 10, scale: 3, if_not_exists: true
    add_column :disbursements, :allowed_apply_vat, :string, if_not_exists: true
  end
end
