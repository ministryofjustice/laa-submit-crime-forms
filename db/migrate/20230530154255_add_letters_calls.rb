class AddLettersCalls < ActiveRecord::Migration[7.0]
  def change
    add_column :claims, :letters, :int
    add_column :claims, :calls, :int
    add_column :claims, :letters_calls_uplift, :int
  end
end
