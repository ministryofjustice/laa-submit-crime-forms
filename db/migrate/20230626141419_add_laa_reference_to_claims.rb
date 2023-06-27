class AddLaaReferenceToClaims < ActiveRecord::Migration[7.0]
  def change
    add_column :claims, :laa_reference, :string
  end
end