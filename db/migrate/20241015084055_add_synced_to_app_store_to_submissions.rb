class AddSyncedToAppStoreToSubmissions < ActiveRecord::Migration[7.2]
  def change
    add_column :claims, :submit_to_app_store_completed, :boolean
    add_column :claims, :send_notification_email_completed, :boolean
    add_column :prior_authority_applications, :submit_to_app_store_completed, :boolean
    add_column :prior_authority_applications, :send_notification_email_completed, :boolean
  end
end
