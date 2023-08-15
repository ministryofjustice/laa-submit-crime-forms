class AddIsOtherInfoToClaims < ActiveRecord::Migration[7.0]
  def change
    add_column :claims, :is_other_info, :string
  end
end