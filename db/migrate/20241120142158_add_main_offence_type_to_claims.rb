class AddMainOffenceTypeToClaims < ActiveRecord::Migration[8.0]
  def change
    add_column :claims, :main_offence_type, :string
  end
end
