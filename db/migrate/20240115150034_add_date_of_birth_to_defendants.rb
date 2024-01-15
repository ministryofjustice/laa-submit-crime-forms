class AddDateOfBirthToDefendants < ActiveRecord::Migration[7.1]
  def change
    add_column :defendants, :date_of_birth, :date
    add_column :defendants, :first_name, :string
    add_column :defendants, :last_name, :string
  end
end
