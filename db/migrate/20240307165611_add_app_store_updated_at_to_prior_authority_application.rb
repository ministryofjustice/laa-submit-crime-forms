class AddAppStoreUpdatedAtToPriorAuthorityApplication < ActiveRecord::Migration[7.1]
  def change
    add_column :prior_authority_applications, :app_store_updated_at, :datetime
  end
end
