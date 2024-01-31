class AddReasonWhy < ActiveRecord::Migration[7.1]
  def change
    add_column :prior_authority_applications, :reason_why, :text

    rename_table :supporting_evidence, :supporting_documents
    add_column :supporting_documents, :documentable_type, :string
    rename_column :supporting_documents, :claim_id, :documentable_id
    add_column :supporting_documents, :document_type, :string

    add_index :supporting_documents, [:documentable_type, :documentable_id]

    remove_foreign_key "supporting_documents", "claims", column: "documentable_id"

    execute <<~SQL
      UPDATE supporting_documents
      SET documentable_type = 'Claim',
        document_type = 'supporting_evidence'
    SQL
  end
end
