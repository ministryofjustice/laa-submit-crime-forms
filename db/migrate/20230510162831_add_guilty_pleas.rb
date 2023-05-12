class AddGuiltyPleas < ActiveRecord::Migration[7.0]
  def change
    remove_column :claims, :plea, :boolean

    add_column :claims, :plea, :string
    add_column :claims, :arrest_warrent_date, :date
    add_column :claims, :cracked_trial_date, :date
  end
end
