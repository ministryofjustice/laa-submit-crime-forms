class AddSignatoryNameToFurtherInformations < ActiveRecord::Migration[7.2]
  def change
    add_column :further_informations, :signatory_name, :string
  end
end
