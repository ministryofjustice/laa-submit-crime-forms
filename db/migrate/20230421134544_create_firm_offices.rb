class CreateFirmOffices < ActiveRecord::Migration[7.0]
  def change
    create_table :firm_offices, id: :uuid do |t|
      t.string :name
      t.string :account_number
      t.string :address_line_1
      t.string :address_line_2
      t.string :town
      t.string :postcode

      t.references :previous, null: true, type: :uuid

      t.timestamps
    end

    add_foreign_key :firm_offices, :firm_offices, column: :previous_id
    add_reference :claims, :firm_office, foreign_key: true, type: :uuid, null: true
  end
end
