class AddProgFieldsToClaim < ActiveRecord::Migration[7.1]
  def change
    add_column :claims, :office_in_undesignated_area, :boolean
    add_column :claims, :court_in_undesignated_area, :boolean
    add_column :claims, :transferred_from_undesignated_area, :boolean
  end
end
