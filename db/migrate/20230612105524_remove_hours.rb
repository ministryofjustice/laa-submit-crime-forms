class RemoveHours < ActiveRecord::Migration[7.0]
  def change
    remove_column :claims, :time_spent_hours, :int
    remove_column :work_items, :hours, :int

    rename_column :claims, :time_spent_mins, :time_spent
    rename_column :work_items, :minutes, :time_spent
  end
end
