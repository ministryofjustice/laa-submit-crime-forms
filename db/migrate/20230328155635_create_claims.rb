class CreateClaims < ActiveRecord::Migration[7.0]
  def change
    create_table :claims, id: :uuid do |t|
      t.string :ufn, index: true
      t.string :office_code, null: false
      t.jsonb :navigation_stack, array: true, default: []

      t.string :claim_type
      t.datetime :rep_order_date
      t.string :cntp_order
      t.datetime :cntp_date

      t.timestamps
    end
  end
end
