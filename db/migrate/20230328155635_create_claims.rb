class CreateClaims < ActiveRecord::Migration[7.0]
  def change
    create_table :claims, id: :uuid do |t|
      t.string :usn, null: false, index: { unique: true }
      t.string :office_code, null: false
      t.jsonb :navigation_stack, array: true, default: []

      t.string :claim_type
      t.string :claim_number
      t.datetime :claim_date

      t.timestamps
    end
  end
end
