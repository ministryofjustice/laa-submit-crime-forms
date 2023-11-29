class AddPleaCategory < ActiveRecord::Migration[7.1]
  def change
    add_column :claims, :plea_category, :string
  end
end
