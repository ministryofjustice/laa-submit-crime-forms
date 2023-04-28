class CreateSolicitors < ActiveRecord::Migration[7.0]
  def change
    create_table :solicitors, id: :uuid do |t|
      t.string :full_name
      t.string :reference_number
      t.string :contact_full_name
      t.string :contact_email
      t.references :previous, null: true, type: :uuid

      t.timestamps
    end

    add_foreign_key :solicitors, :solicitors, column: :previous_id
    add_reference :claims, :solicitor, foreign_key: true, type: :uuid, null: true
  end
end
