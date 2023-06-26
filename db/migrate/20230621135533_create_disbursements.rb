class CreateDisbursements < ActiveRecord::Migration[7.0]
  def change
    create_table :disbursements, id: :uuid do |t|
      t.references :claim, null: false, foreign_key: true, type: :uuid
      t.date :disbursement_date
      t.string :disbursement_type
      t.string :other_type
      t.string :miles
      t.float :total_cost
      t.text :details
      t.string :prior_authority
      t.string :apply_vat

      t.timestamps
    end
  end
end
