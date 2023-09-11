class AddFilePathForEvidence < ActiveRecord::Migration[7.0]
  def change
    add_column "supporting_evidence", :file_path, :string
  end
end
