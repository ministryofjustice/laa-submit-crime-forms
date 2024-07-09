class AddWorkCompletedDate < ActiveRecord::Migration[7.1]
  def change
    add_column :claims, :work_completed_date, :date
  end
end
