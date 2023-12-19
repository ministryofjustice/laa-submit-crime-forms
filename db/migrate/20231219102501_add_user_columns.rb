class AddUserColumns < ActiveRecord::Migration[7.1]
  def change
    change_table :users, bulk: true do |t|
      t.string "first_name"
      t.string "last_name"
      t.string "role"
      t.datetime "last_auth_at"
      t.datetime "first_auth_at"
      t.datetime "deactivated_at"
      t.datetime "invitation_expires_at"
    end

    rename_column :users, :uid, :auth_uid
  end
end
