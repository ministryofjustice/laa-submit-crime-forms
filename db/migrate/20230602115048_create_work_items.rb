class CreateWorkItems < ActiveRecord::Migration[7.0]
  def change
    create_table :work_items, id: :uuid do |t|
      t.references :claim, null: false, foreign_key: true, type: :uuid
      t.string :work_type
      t.integer :hours
      t.integer :minutes
      t.date :completed_on
      t.string :fee_earner
      t.integer :uplift

      t.timestamps
    end
  end
end
