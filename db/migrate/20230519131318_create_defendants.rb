class CreateDefendants < ActiveRecord::Migration[7.0]
  def change
    create_table :defendants, id: :uuid do |t|
      t.references :claim, null: false, foreign_key: true, type: :uuid
      t.string :full_name
      t.string :maat
      t.integer :position
      t.boolean :main, default: false

      t.timestamps
    end
  end
end
