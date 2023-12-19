class RenameProvidersToUsers < ActiveRecord::Migration[7.1]
  def change
    rename_table :providers, :users
  end
end
