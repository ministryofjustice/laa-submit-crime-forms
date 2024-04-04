class RemoveExiredAtFromFurtherInformations < ActiveRecord::Migration[7.1]
  def change
    remove_column :further_informations, :expired_at
  end
end
