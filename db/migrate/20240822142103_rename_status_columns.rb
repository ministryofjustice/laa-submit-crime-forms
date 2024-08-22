class RenameStatusColumns < ActiveRecord::Migration[7.2]
  def change
    rename_column :claims, :status, :state
    rename_column :prior_authority_applications, :status, :state
  end
end
