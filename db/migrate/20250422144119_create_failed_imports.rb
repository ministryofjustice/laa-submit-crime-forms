class CreateFailedImports < ActiveRecord::Migration[8.0]
  def change
    create_table "failed_imports", id: :uuid do |t|
      t.string "details"
      t.timestamps

      t.belongs_to :provider
    end
  end
end
