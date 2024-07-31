class AddPosition < ActiveRecord::Migration[7.1]
  def change
    add_column :work_items, :position, :integer
  end
end
