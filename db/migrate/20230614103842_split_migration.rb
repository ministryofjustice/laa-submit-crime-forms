class SplitMigration < ActiveRecord::Migration[7.0]
  def change
    add_column :claims, :other_info, :text
    add_column :claims, :conclusion, :text
    add_column :claims, :concluded, :string
  end
end
