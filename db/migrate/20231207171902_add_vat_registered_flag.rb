class AddVatRegisteredFlag < ActiveRecord::Migration[7.1]
  def change
    add_column :firm_offices, :vat_registered, :boolean
  end
end
