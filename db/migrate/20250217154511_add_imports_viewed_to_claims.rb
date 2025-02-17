class AddImportsViewedToClaims < ActiveRecord::Migration[8.0]
  def change
    add_column :claims, :imported_work_items_viewed, :boolean, default: false
    add_column :claims, :imported_disbursements_viewed, :boolean, default: false
  end
end
