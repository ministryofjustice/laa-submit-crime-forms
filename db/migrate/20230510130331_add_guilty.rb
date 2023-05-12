class AddGuilty < ActiveRecord::Migration[7.0]
  def change
    add_column :claims, :plea, :string
  end
end
