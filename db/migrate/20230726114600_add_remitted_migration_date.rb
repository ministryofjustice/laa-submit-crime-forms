class AddRemittedMigrationDate < ActiveRecord::Migration[7.0]
  def change
    add_column :claims, :remitted_to_magistrate_date  , :date
  end
end
