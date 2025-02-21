class AddImportDateToClaims < ActiveRecord::Migration[8.0]
  def change
    add_column :claims, :import_date, :datetime
  end
end
