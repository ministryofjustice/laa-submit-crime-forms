class CreateDates < ActiveRecord::Migration[7.0]
  def change
    add_column :claims, :work_before_date, :date
    add_column :claims, :work_after_date, :date
  end
end
