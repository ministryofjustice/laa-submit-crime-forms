class AddStatusToFurtherInformations < ActiveRecord::Migration[7.1]
  def change
    add_column :further_informations, :status, :string
  end
end
