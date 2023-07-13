class AddSolicitorDeclarationName < ActiveRecord::Migration[7.0]
  def change
    add_column :claims, :signatory_name, :string
  end
end
