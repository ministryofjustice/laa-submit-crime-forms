class AppStoreUpdatedAt < ActiveRecord::Migration[7.1]
  def change
    add_column :claims, :app_store_updated_at, :datetime

    execute <<~SQL
      UPDATE claims
      SET app_store_updated_at = CURRENT_TIMESTAMP
    SQL
  end
end
