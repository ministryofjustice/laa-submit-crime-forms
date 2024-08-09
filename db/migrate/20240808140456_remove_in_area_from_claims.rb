class RemoveInAreaFromClaims < ActiveRecord::Migration[7.1]
  def change
    remove_column :claims, :in_area, :boolean
  end
end
