class AddTableFurtherInformation < ActiveRecord::Migration[7.1]
  def change
    create_table :further_informations, id: :uuid do |t|
      t.string :information_requested
      t.string :information_supplied

      t.timestamps
    end

    add_reference :further_informations, :prior_authority_application, foreign_key: true, type: :uuid, null: false
  end
end
