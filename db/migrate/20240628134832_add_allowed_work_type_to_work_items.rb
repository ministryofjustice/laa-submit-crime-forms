class AddAllowedWorkTypeToWorkItems < ActiveRecord::Migration[7.1]
  def change
    add_column :work_items, :allowed_work_type, :string
  end
end
