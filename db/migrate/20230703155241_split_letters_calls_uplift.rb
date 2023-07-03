class SplitLettersCallsUplift < ActiveRecord::Migration[7.0]
  def change
    add_column :claims, :letters_uplift, :integer
    rename_column :claims,  :letters_calls_uplift, :calls_uplift
  end
end
