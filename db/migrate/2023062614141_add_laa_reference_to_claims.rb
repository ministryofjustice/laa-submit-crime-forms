class AddLaaReferenceToClaims < ActiveRecord::Migration[6.1]
  def change
    add_column :claims, :laa_reference, :string
  end
end