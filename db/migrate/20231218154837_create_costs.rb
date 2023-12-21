class CreateCosts < ActiveRecord::Migration[7.1]
  def change
    create_table :costs, id: :uuid do |t|
      t.references :claim, null: false, foreign_key: true, type: :uuid
      t.string :type, null: false
      t.float :amount, null: false
      t.float :amount_with_vat
    end
  end
end
