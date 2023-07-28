class AddSendByPostToClaims < ActiveRecord::Migration[7.0]
  def change
    add_column :claims, :send_by_post, :boolean
  end
end
