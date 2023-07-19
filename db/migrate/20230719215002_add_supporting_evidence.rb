class AddSupportingEvidence < ActiveRecord::Migration[7.0]
  def change
    create_table :supporting_evidence, id: :uuid do |t|
      t.references :claim, null: false, foreign_key: true, type: :uuid
      t.string :file_name
      t.string :file_type
      t.integer :file_size
      t.string :case_id

      t.timestamps
    end
  end
end
