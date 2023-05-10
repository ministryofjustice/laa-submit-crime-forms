class AddGuiltyPleas < ActiveRecord::Migration[7.0]
  def change
    add_column :claims, :guilty_pleas, :jsonb, default: []
  end
end
